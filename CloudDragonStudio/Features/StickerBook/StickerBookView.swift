import SwiftUI

struct StickerBookView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var localization: LocalizationService
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    private var reduceMotion: Bool {
        container.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    var body: some View {
        GeometryReader { geo in
            let cols = geo.size.width > 650 ? 3 : 2
            ZStack {
                CloudBackdropView(reduceMotion: reduceMotion)

                VStack(spacing: 12) {
                    TopNavBar(
                        title: localization.text("mode.sticker_book"),
                        subtitle: localization.text("stickers.subtitle"),
                        backLabel: localization.text("nav.home"),
                        onBack: { router.popToHome() }
                    )

                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: cols), spacing: 12) {
                            ForEach(StickerDefinition.allStickers) { sticker in
                                let unlocked = container.saveData.collectedStickerIDs.contains(sticker.id)
                                VStack(spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(unlocked ? sticker.tint.swiftUIColor.opacity(0.35) : PastelPalette.cardBorder.swiftUIColor.opacity(0.45))
                                            .frame(width: 62, height: 62)
                                        Image(systemName: sticker.symbol)
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundStyle(unlocked ? PastelPalette.textDark.swiftUIColor : PastelPalette.textMuted.swiftUIColor.opacity(0.5))
                                    }

                                    Text(sticker.localizedTitle(localization.language))
                                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                                        .foregroundStyle(unlocked ? PastelPalette.textDark.swiftUIColor : PastelPalette.textMuted.swiftUIColor)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, minHeight: 120)
                                .background(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .fill(unlocked ? PastelPalette.butterWarm.swiftUIColor : .white.opacity(0.82))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                                .stroke(unlocked ? PastelPalette.butterDark.swiftUIColor : PastelPalette.cardBorder.swiftUIColor, lineWidth: 2)
                                        )
                                )
                                .accessibilityIdentifier("sticker.\(sticker.id)")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
