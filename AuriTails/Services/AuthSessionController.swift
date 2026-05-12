import Combine
import FirebaseAuth
import FirebaseCore
import FirebaseCrashlytics
import Foundation
import SwiftUI

@MainActor
final class AuthSessionController: ObservableObject {
    struct SessionUser: Equatable {
        let id: String?
        let email: String
    }

    enum Phase: Equatable {
        case notConfigured
        case signedOut
        case sendingLink
        case linkSent(String)
        case signedIn(SessionUser)
        case error(String)
    }

    @Published private(set) var phase: Phase

    let configuration: FirebaseConfiguration?

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private let pendingEmailKey = "com.auritails.firebase.pendingEmail"

    init(configuration: FirebaseConfiguration? = nil) {
        let resolvedConfiguration = configuration ?? FirebaseConfiguration.load()
        self.configuration = resolvedConfiguration

        if resolvedConfiguration != nil {
            Self.configureFirebaseIfNeeded()
            self.phase = .signedOut
        } else {
            self.phase = .notConfigured
        }

        startAuthStateListenerIfNeeded()
        updatePhaseFromCurrentUserIfNeeded()
        refreshDiagnosticsContext()
    }

    deinit {
        if let authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
    }

    var isConfigured: Bool {
        configuration != nil && FirebaseApp.app() != nil
    }

    var signedInEmail: String? {
        if case let .signedIn(user) = phase {
            return user.email
        }
        return nil
    }

    var statusTitle: String {
        switch phase {
        case .notConfigured:
            return "Firebase not connected"
        case .signedOut:
            return "Sign in for cloud restore"
        case .sendingLink:
            return "Sending email link"
        case let .linkSent(email):
            return "Check \(email)"
        case let .signedIn(user):
            return "Signed in as \(user.email)"
        case .error:
            return "Cloud sign-in paused"
        }
    }

    var statusDetail: String {
        switch phase {
        case .notConfigured:
            return "Add GoogleService-Info.plist and a FIREBASE_EMAIL_LINK_URL before turning on live family sharing. Until then, AuriTails stays local-first."
        case .signedOut:
            return "Firebase auth is ready to back up your pet profiles, routines, wellness records, memories, and Care Circle data under your account."
        case .sendingLink:
            return "AuriTails is preparing a Firebase email link for your Care Circle account."
        case .linkSent:
            return "Open the email on this device and come back through the link so we can complete sign-in automatically."
        case .signedIn:
            return "This device is connected to Firebase for account restore, Care Circle membership, analytics, and crash reporting."
        case let .error(message):
            return message
        }
    }

    func sendMagicLink(to email: String) async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedEmail.isEmpty else {
            phase = .error("Enter an email address first.")
            refreshDiagnosticsContext()
            return
        }

        guard let configuration, FirebaseApp.app() != nil else {
            phase = .notConfigured
            refreshDiagnosticsContext()
            return
        }

        if let validationMessage = configuration.validationMessage {
            phase = .error(validationMessage)
            refreshDiagnosticsContext()
            return
        }

        phase = .sendingLink
        refreshDiagnosticsContext()

        let settings = ActionCodeSettings()
        settings.url = configuration.emailLinkURL
        settings.handleCodeInApp = true
        settings.setIOSBundleID(configuration.bundleID)

        do {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
                Auth.auth().sendSignInLink(toEmail: trimmedEmail, actionCodeSettings: settings) { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }

            UserDefaults.standard.set(trimmedEmail, forKey: pendingEmailKey)
            FirebaseTelemetry.logEvent("care_circle_sign_in_started", parameters: [
                "method": "email_link",
            ])
            phase = .linkSent(trimmedEmail)
        } catch {
            FirebaseTelemetry.record(error: error, context: "care_circle_sign_in_started")
            phase = .error(Self.describeAuthError(error, configuration: configuration))
        }

        refreshDiagnosticsContext()
    }

    #if DEBUG
    func markSignedIn(email: String) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedEmail.isEmpty else { return }
        phase = .signedIn(SessionUser(id: nil, email: trimmedEmail))
        refreshDiagnosticsContext()
    }
    #endif

    func signOut() async {
        guard FirebaseApp.app() != nil else {
            phase = .notConfigured
            refreshDiagnosticsContext()
            return
        }

        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: pendingEmailKey)
            FirebaseTelemetry.logEvent("care_circle_sign_out")
            phase = .signedOut
        } catch {
            FirebaseTelemetry.record(error: error, context: "care_circle_sign_out")
            phase = .error(Self.describeAuthError(error, configuration: configuration))
        }

        refreshDiagnosticsContext()
    }

    func handleIncomingURL(_ url: URL) {
        guard FirebaseApp.app() != nil else { return }

        let absoluteString = url.absoluteString
        guard Auth.auth().isSignIn(withEmailLink: absoluteString) else { return }

        guard let email = UserDefaults.standard.string(forKey: pendingEmailKey),
              !email.isEmpty
        else {
            phase = .error("The sign-in link opened, but the email used to request it is no longer on this device. Request a new link and try again.")
            refreshDiagnosticsContext()
            return
        }

        Task {
            do {
                let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AuthDataResult, any Error>) in
                    Auth.auth().signIn(withEmail: email, link: absoluteString) { result, error in
                        if let error {
                            continuation.resume(throwing: error)
                        } else if let result {
                            continuation.resume(returning: result)
                        } else {
                            continuation.resume(throwing: NSError(domain: "AuriTails.FirebaseAuth", code: -1, userInfo: [
                                NSLocalizedDescriptionKey: "Firebase did not return a sign-in result.",
                            ]))
                        }
                    }
                }

                UserDefaults.standard.removeObject(forKey: pendingEmailKey)
                FirebaseTelemetry.logEvent("care_circle_sign_in_completed", parameters: [
                    "method": "email_link",
                    "has_user_id": result.user.uid.isEmpty ? 0 : 1,
                ])
                phase = .signedIn(
                    SessionUser(
                        id: result.user.uid,
                        email: result.user.email?.lowercased() ?? email
                    )
                )
            } catch {
                FirebaseTelemetry.record(error: error, context: "care_circle_sign_in_completed")
                phase = .error(error.localizedDescription)
            }

            refreshDiagnosticsContext()
        }
    }

    private func startAuthStateListenerIfNeeded() {
        guard FirebaseApp.app() != nil else { return }

        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }

            Task { @MainActor in
                if let user, let email = user.email?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty {
                    self.phase = .signedIn(SessionUser(id: user.uid, email: email.lowercased()))
                } else if self.phase != .notConfigured, !self.isSendingOrWaitingForLink {
                    self.phase = .signedOut
                }
                self.refreshDiagnosticsContext()
            }
        }
    }

    private var isSendingOrWaitingForLink: Bool {
        switch phase {
        case .sendingLink, .linkSent:
            return true
        default:
            return false
        }
    }

    private func updatePhaseFromCurrentUserIfNeeded() {
        guard FirebaseApp.app() != nil else { return }

        if let user = Auth.auth().currentUser,
           let email = user.email?.trimmingCharacters(in: .whitespacesAndNewlines),
           !email.isEmpty
        {
            phase = .signedIn(SessionUser(id: user.uid, email: email.lowercased()))
        }
    }

    private func refreshDiagnosticsContext() {
        guard FirebaseApp.app() != nil else { return }

        let mode: String = {
            switch phase {
            case .notConfigured:
                return "not_configured"
            case .signedOut:
                return "signed_out"
            case .sendingLink:
                return "sending_link"
            case .linkSent:
                return "link_sent"
            case .signedIn:
                return "signed_in"
            case .error:
                return "error"
            }
        }()

        let crashlytics = FirebaseCrashlytics.Crashlytics.crashlytics()
        crashlytics.setCustomValue(isConfigured, forKey: "firebase_configured")
        crashlytics.setCustomValue(mode, forKey: "care_circle_auth_phase")
        FirebaseTelemetry.setUserProperties(authPhase: mode, firebaseConfigured: isConfigured)
    }

    private static func configureFirebaseIfNeeded() {
        guard FirebaseApp.app() == nil else { return }
        FirebaseApp.configure()
    }

    private static func describeAuthError(_ error: Error, configuration: FirebaseConfiguration?) -> String {
        let nsError = error as NSError
        let baseMessage = nsError.localizedDescription

        var hints: [String] = []

        if let validationMessage = configuration?.validationMessage {
            hints.append(validationMessage)
        }

        if let host = configuration?.emailLinkURL.host?.lowercased() {
            hints.append("Make sure \(host) is listed in Firebase Authentication > Settings > Authorized domains.")
        }

        hints.append("Confirm Email link sign-in is enabled in Firebase Authentication > Sign-in method.")

        let diagnostic = "Firebase error \(nsError.domain) (\(nsError.code))."
        let joinedHints = hints.joined(separator: " ")
        return joinedHints.isEmpty ? "\(baseMessage) \(diagnostic)" : "\(baseMessage) \(diagnostic) \(joinedHints)"
    }
}
