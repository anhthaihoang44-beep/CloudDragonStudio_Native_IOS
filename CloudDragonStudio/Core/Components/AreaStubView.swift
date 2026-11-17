import SwiftUI

struct AreaStubView: View {
    let titleKey: String
    let descKey: String
    let symbol: String
    let accent: CodableColor

    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var localization: LocalizationService
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    private var reduceMotion: Bool {
        container.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    var body: some View {
        ZStack {
            CloudBackdropView(reduceMotion: reduceMotion)

            VStack(spacing: 16) {
                TopNavBar(
                    title: localization.text(titleKey),
                    backLabel: localization.text("nav.home"),
                    onBack: { router.popToHome() }
                )

                Spacer()

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(accent.swiftUIColor.opacity(0.35))
                            .frame(width: 96, height: 96)
                        Image(systemName: symbol)
                            .font(.system(size: 42, weight: .bold))
                            .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                    }

                    DragonView(character: container.character, reduceMotion: reduceMotion)
                        .frame(width: 220, height: 220)

                    Text(localization.text(descKey))
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                        .multilineTextAlignment(.center)

                    Text(localization.text("stub.coming_next"))
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(PastelPalette.mutedText.swiftUIColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.white.opacity(0.86)))
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.white.opacity(0.68))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(.white.opacity(0.9), lineWidth: 2)
                        )
                )
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
