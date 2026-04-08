import Foundation

struct FirebaseConfiguration: Equatable {
    let emailLinkURL: URL
    let bundleID: String
    let hasGoogleServiceInfo: Bool

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

        return FirebaseConfiguration(
            emailLinkURL: emailLinkURL,
            bundleID: bundleID,
            hasGoogleServiceInfo: hasGoogleServiceInfo
        )
    }
}
