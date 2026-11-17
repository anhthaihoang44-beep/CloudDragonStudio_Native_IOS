import SwiftUI

@MainActor
final class AppContainer: ObservableObject {
    @Published var character: CloudDragonCharacter = .defaultDragon
    @Published var reduceMotionPreference: Bool {
        didSet {
            UserDefaults.standard.set(reduceMotionPreference, forKey: Self.reduceMotionKey)
        }
    }

    let router = AppRouter()
    let localization = LocalizationService()
    let haptics = HapticsService()

    private static let reduceMotionKey = "cloud_dragon_reduce_motion"

    init() {
        self.reduceMotionPreference = UserDefaults.standard.bool(forKey: Self.reduceMotionKey)
    }

    func effectiveReduceMotion(systemReduceMotion: Bool) -> Bool {
        systemReduceMotion || reduceMotionPreference
    }
}
