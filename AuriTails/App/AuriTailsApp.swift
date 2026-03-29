import SwiftUI

@main
struct AuriTailsApp: App {
    @StateObject private var viewModel = AppViewModel.preview()

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: viewModel)
        }
    }
}
