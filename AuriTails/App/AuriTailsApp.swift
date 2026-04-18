import FirebaseCore
import SwiftUI

@main
struct AuriTailsApp: App {
    @StateObject private var viewModel: AppViewModel
    @StateObject private var authController: AuthSessionController

    init() {
        FirebaseConfiguration.configureAppIfPossible()
        _viewModel = StateObject(wrappedValue: AppViewModel(seed: .empty))
        _authController = StateObject(wrappedValue: AuthSessionController())
    }

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: viewModel)
                .environmentObject(authController)
                .onOpenURL { url in
                    authController.handleIncomingURL(url)
                }
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                    guard let url = userActivity.webpageURL else { return }
                    authController.handleIncomingURL(url)
                }
        }
    }
}
