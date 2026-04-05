import SwiftUI

@main
struct AuriTailsApp: App {
    @StateObject private var viewModel = AppViewModel(seed: .empty)

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: viewModel)
        }
    }
}
