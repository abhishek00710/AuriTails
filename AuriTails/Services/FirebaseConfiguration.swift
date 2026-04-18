import FirebaseCore
import Foundation

struct FirebaseConfiguration: Equatable {
    // Kept in this file temporarily for backwards compatibility; rename the file to match when convenient.
    let emailLinkURL: URL
    let bundleID: String
    let hasGoogleServiceInfo: Bool
    let projectID: String?

    var validationMessage: String? {
        guard let scheme = emailLinkURL.scheme?.lowercased(), scheme == "https" else {
            return "FIREBASE_EMAIL_LINK_URL must be an https URL that is authorized in Firebase Authentication."
        }

        if let host = emailLinkURL.host?.lowercased(), host.hasSuffix(".page.link") {
            let suggestedHost = (projectID?.isEmpty == false ? "\(projectID!).firebaseapp.com" : "YOUR_PROJECT_ID.firebaseapp.com")
            return "FIREBASE_EMAIL_LINK_URL is using a Dynamic Links domain (\(host)), which is not the right setup for the current Apple email-link flow. Use a Firebase Hosting domain such as https://\(suggestedHost)/auth and add that domain under Firebase Authentication > Settings > Authorized domains."
        }

        return nil
    }

    static func configureAppIfPossible(from bundle: Bundle = .main) {
        guard FirebaseApp.app() == nil else { return }
        guard bundle.path(forResource: "GoogleService-Info", ofType: "plist") != nil else { return }
        FirebaseApp.configure()
    }

    static func load(from bundle: Bundle = .main) -> FirebaseConfiguration? {
        let info = bundle.infoDictionary ?? [:]

        guard let rawEmailLinkURL = info["FIREBASE_EMAIL_LINK_URL"] as? String,
              let emailLinkURL = URL(string: rawEmailLinkURL),
              let bundleID = bundle.bundleIdentifier,
              !bundleID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return nil
        }

        let hasGoogleServiceInfo = bundle.path(forResource: "GoogleService-Info", ofType: "plist") != nil
        guard hasGoogleServiceInfo else { return nil }

        let projectID: String? = {
            guard let path = bundle.path(forResource: "GoogleService-Info", ofType: "plist"),
                  let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any]
            else {
                return nil
            }

            return dictionary["PROJECT_ID"] as? String
        }()

        return FirebaseConfiguration(
            emailLinkURL: emailLinkURL,
            bundleID: bundleID,
            hasGoogleServiceInfo: hasGoogleServiceInfo,
            projectID: projectID
        )
    }
}
