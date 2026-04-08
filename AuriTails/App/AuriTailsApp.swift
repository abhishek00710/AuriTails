import SwiftUI

@main
struct AuriTailsApp: App {
    @StateObject private var viewModel = AppViewModel(seed: .empty)
    @StateObject private var authController = AuthSessionController()

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: viewModel)
                .environmentObject(authController)
                .onOpenURL { url in
                    authController.handleIncomingURL(url)
                }
        }
    }
}
