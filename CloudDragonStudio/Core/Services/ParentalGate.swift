import Foundation

struct ParentalGateChallenge: Equatable, Sendable {
    let left: Int
    let right: Int

    var expectedAnswer: Int { left * right }

    var equationText: String {
        "\(left) × \(right) = ?"
    }

    static func generate() -> ParentalGateChallenge {
        ParentalGateChallenge(
            left: Int.random(in: 4...9),
            right: Int.random(in: 4...9)
        )
    }
}
