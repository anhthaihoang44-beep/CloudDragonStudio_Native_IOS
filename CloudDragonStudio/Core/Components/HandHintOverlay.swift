import SwiftUI

struct HandHintOverlay: View {
    let message: String
    let reduceMotion: Bool
    @State private var animate = false

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "hand.point.up.left.fill")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                .padding(10)
                .background(
                    Circle()
                        .fill(.white.opacity(0.92))
                        .shadow(color: PastelPalette.lavenderDeep.swiftUIColor.opacity(0.25), radius: 8, y: 4)
                )
                .offset(
                    x: reduceMotion ? 0 : (animate ? 36 : -36),
                    y: reduceMotion ? 0 : (animate ? -10 : 10)
                )
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                    value: animate
                )

            Text(message)
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(.white.opacity(0.92)))
        }
        .allowsHitTesting(false)
        .onAppear {
            if !reduceMotion {
                animate = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}
