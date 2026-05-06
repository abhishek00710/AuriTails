import StoreKit
import UIKit

struct AppReviewPrompter {
    @MainActor
    func requestReviewIfPossible() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        else {
            return
        }

        AppStore.requestReview(in: scene)
    }

    var currentAppVersion: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
