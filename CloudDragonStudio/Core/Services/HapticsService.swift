import UIKit

@MainActor
final class HapticsService: ObservableObject {
    @Published var isEnabled: Bool = true
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let softGenerator = UIImpactFeedbackGenerator(style: .soft)

    func tap(reduceMotion: Bool = false) {
        guard isEnabled, !reduceMotion else { return }
        lightGenerator.impactOccurred(intensity: 0.55)
    }

    func sparkle(reduceMotion: Bool = false) {
        guard isEnabled, !reduceMotion else { return }
        softGenerator.impactOccurred(intensity: 0.7)
    }
}
