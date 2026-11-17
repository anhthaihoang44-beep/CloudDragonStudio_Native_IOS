import SwiftUI

@main
struct CloudDragonStudioApp: App {
    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(container)
                .environmentObject(container.router)
                .environmentObject(container.localization)
                .environmentObject(container.haptics)
        }
    }
}

private struct RootNavigationView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var localization: LocalizationService

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: AppDestination.self) { destination in
                    destinationView(for: destination)
                        .navigationBarBackButtonHidden(true)
                }
        }
        .environment(\.locale, Locale(identifier: localization.language.rawValue))
    }

    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .cloudBath:
            CloudBathView()
        case .scaleStudio:
            ScaleStudioView()
        case .wardrobe:
            WardrobeView()
        case .bakeNook:
            BakeNookView()
        case .petGarden:
            PetGardenView()
        case .photoBooth:
            PhotoBoothView()
        case .freeStudio:
            FreeStudioView()
        case .dailyWish:
            DailyWishView()
        case .stickerBook:
            StickerBookView()
        case .settings:
            SettingsView()
        }
    }
}
