import SwiftUI

enum AppDestination: String, Hashable, CaseIterable, Identifiable {
    case cloudBath
    case scaleStudio
    case wardrobe
    case bakeNook
    case petGarden
    case photoBooth
    case freeStudio
    case dailyWish
    case stickerBook
    case settings

    var id: String { rawValue }
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var path: [AppDestination] = []

    func open(_ destination: AppDestination) {
        if path.last != destination {
            path.append(destination)
        }
    }

    func popToHome() {
        path.removeAll()
    }
}
