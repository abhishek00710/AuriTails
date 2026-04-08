import Combine
import FirebaseAnalytics
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
            return "Sign in for shared Care Circle"
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
            return "Firebase auth is ready when you want real Care Circle members, Analytics, and Crashlytics-backed cloud features."
        case .sendingLink:
            return "AuriTails is preparing a Firebase email link for your Care Circle account."
        case .linkSent:
            return "Open the email on this device and come back through the link so we can complete sign-in automatically."
        case .signedIn:
            return "This device is connected to Firebase for real Care Circle membership, analytics, and crash reporting."
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
            Analytics.logEvent("care_circle_sign_in_started", parameters: [
                "method": "email_link",
            ])
            phase = .linkSent(trimmedEmail)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            phase = .error(error.localizedDescription)
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
            Analytics.logEvent("care_circle_sign_out", parameters: nil)
            phase = .signedOut
        } catch {
            Crashlytics.crashlytics().record(error: error)
            phase = .error(error.localizedDescription)
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
                Analytics.setUserID(result.user.uid)
                Analytics.logEvent("care_circle_sign_in_completed", parameters: [
                    "method": "email_link",
                ])
                phase = .signedIn(
                    SessionUser(
                        id: result.user.uid,
                        email: result.user.email?.lowercased() ?? email
                    )
                )
            } catch {
                Crashlytics.crashlytics().record(error: error)
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

        Crashlytics.crashlytics().setCustomValue(isConfigured, forKey: "firebase_configured")
        Crashlytics.crashlytics().setCustomValue(mode, forKey: "care_circle_auth_phase")
        Analytics.setUserProperty(mode, forName: "care_circle_auth_phase")
        Analytics.setUserProperty(isConfigured ? "true" : "false", forName: "firebase_configured")
    }

    private static func configureFirebaseIfNeeded() {
        guard FirebaseApp.app() == nil else { return }
        FirebaseApp.configure()
    }
}
