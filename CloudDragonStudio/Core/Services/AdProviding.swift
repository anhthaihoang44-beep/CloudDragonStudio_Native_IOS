import Foundation

@MainActor
protocol AdProviding: AnyObject {
    var minimumIntervalSeconds: TimeInterval { get }
    func canPresentTransitionInterstitial(isPremium: Bool, isPainting: Bool, now: Date) -> Bool
    @discardableResult
    func presentTransitionInterstitialIfAllowed(isPremium: Bool, isPainting: Bool, now: Date) -> Bool
    func presentOptionalRewardedExtra(onReward: @escaping () -> Void)
}

@MainActor
final class MockAdService: ObservableObject, AdProviding {
    let minimumIntervalSeconds: TimeInterval = 180.0
    private(set) var lastInterstitialDate: Date?
    @Published private(set) var lastInterstitialShownAt: Date?

    func canPresentTransitionInterstitial(
        isPremium: Bool,
        isPainting: Bool,
        now: Date = Date()
    ) -> Bool {
        // Kids-safe rules: never when Premium, never during painting, >= 3 minutes apart
        guard !isPremium, !isPainting else { return false }
        guard let last = lastInterstitialDate else { return true }
        return now.timeIntervalSince(last) >= minimumIntervalSeconds
    }

    @discardableResult
    func presentTransitionInterstitialIfAllowed(
        isPremium: Bool,
        isPainting: Bool,
        now: Date = Date()
    ) -> Bool {
        guard canPresentTransitionInterstitial(isPremium: isPremium, isPainting: isPainting, now: now) else {
            return false
        }
        lastInterstitialDate = now
        lastInterstitialShownAt = now
        return true
    }

    func presentOptionalRewardedExtra(onReward: @escaping () -> Void) {
        // Mock implementation grants decorative extra cleanly without real ad SDK or PII tracking
        onReward()
    }
}
