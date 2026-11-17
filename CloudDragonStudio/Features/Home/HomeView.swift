import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var localization: LocalizationService
    @EnvironmentObject private var haptics: HapticsService
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    private var reduceMotion: Bool {
        container.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            let isPadLike = geo.size.width >= 700

            ZStack {
                CloudBackdropView(reduceMotion: reduceMotion)

                VStack(spacing: 10) {
                    headerBar

                    if isLandscape {
                        HStack(spacing: 20) {
                            dragonShowcaseCard
                                .frame(maxWidth: isPadLike ? 400 : geo.size.width * 0.38)
                            VStack(spacing: 14) {
                                Spacer(minLength: 0)
                                areasGrid(columnsCount: isPadLike ? 3 : 2, compactPhone: false)
                                modesRow
                                Spacer(minLength: 0)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 14)
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 14) {
                                dragonShowcaseCard
                                    .frame(height: min(260, geo.size.height * 0.34))
                                areasGrid(columnsCount: 2, compactPhone: true)
                                modesRow
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 18)
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var headerBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(localization.text("app.title"))
                    .font(.system(.title2, design: .rounded).weight(.heavy))
                    .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                    .minimumScaleFactor(0.75)
                    .lineLimit(1)
                Text(localization.text("app.subtitle"))
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(PastelPalette.mutedText.swiftUIColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer()

            Button {
                haptics.tap(reduceMotion: reduceMotion)
                router.open(.settings)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text(localization.text("mode.settings"))
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .lineLimit(1)
                }
                .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                .padding(.horizontal, 14)
                .frame(minWidth: 48, minHeight: 48)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.92))
                        .shadow(color: PastelPalette.lavenderDeep.swiftUIColor.opacity(0.16), radius: 6, y: 3)
                )
            }
            .accessibilityIdentifier("nav.settings")
            .accessibilityLabel(localization.text("mode.settings"))
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
    }

    private var dragonShowcaseCard: some View {
        VStack(spacing: 8) {
            DragonView(
                character: container.character,
                reduceMotion: reduceMotion,
                zonePaintImages: container.zonePaintImages
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Text(localization.text("home.dragon_greeting"))
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.86))
                )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.white.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(.white.opacity(0.85), lineWidth: 2)
                )
        )
    }

    private func areasGrid(columnsCount: Int, compactPhone: Bool) -> some View {
        let items: [AreaTileModel] = [
            AreaTileModel(
                destination: .cloudBath,
                titleKey: "area.bath",
                descKey: "area.bath.desc",
                tint: PastelPalette.skyTop,
                accent: PastelPalette.mintDeep,
                symbol: "bubbles.and.sparkles.fill",
                accessibilityId: "nav.cloudBath"
            ),
            AreaTileModel(
                destination: .scaleStudio,
                titleKey: "area.scale",
                descKey: "area.scale.desc",
                tint: PastelPalette.mint,
                accent: PastelPalette.mintDeep,
                symbol: "paintbrush.pointed.fill",
                accessibilityId: "nav.scaleStudio"
            ),
            AreaTileModel(
                destination: .wardrobe,
                titleKey: "area.wardrobe",
                descKey: "area.wardrobe.desc",
                tint: PastelPalette.lavender,
                accent: PastelPalette.lavenderDeep,
                symbol: "crown.fill",
                accessibilityId: "nav.wardrobe"
            ),
            AreaTileModel(
                destination: .bakeNook,
                titleKey: "area.bake",
                descKey: "area.bake.desc",
                tint: PastelPalette.butterYellow,
                accent: PastelPalette.butterGold,
                symbol: "birthday.cake.fill",
                accessibilityId: "nav.bakeNook"
            ),
            AreaTileModel(
                destination: .petGarden,
                titleKey: "area.pets",
                descKey: "area.pets.desc",
                tint: PastelPalette.peach,
                accent: PastelPalette.coralBlush,
                symbol: "pawprint.fill",
                accessibilityId: "nav.petGarden"
            ),
            AreaTileModel(
                destination: .photoBooth,
                titleKey: "area.photo",
                descKey: "area.photo.desc",
                tint: PastelPalette.cardSurface,
                accent: PastelPalette.lavenderDeep,
                symbol: "camera.fill",
                accessibilityId: "nav.photoBooth"
            )
        ]

        let cols = Array(repeating: GridItem(.flexible(), spacing: 12), count: columnsCount)
        return LazyVGrid(columns: cols, spacing: 12) {
            ForEach(items) { item in
                AreaCardButton(
                    title: localization.text(item.titleKey),
                    subtitle: localization.text(item.descKey),
                    tint: item.tint.swiftUIColor,
                    accent: item.accent.swiftUIColor,
                    symbol: item.symbol,
                    compactPhone: compactPhone
                ) {
                    haptics.tap(reduceMotion: reduceMotion)
                    router.open(item.destination)
                }
                .accessibilityIdentifier(item.accessibilityId)
            }
        }
    }

    private var modesRow: some View {
        HStack(spacing: 10) {
            ModePillButton(
                title: localization.text("mode.free_studio"),
                symbol: "square.grid.2x2.fill",
                tint: PastelPalette.mint.swiftUIColor
            ) {
                haptics.tap(reduceMotion: reduceMotion)
                router.open(.freeStudio)
            }
            .accessibilityIdentifier("nav.freeStudio")

            ModePillButton(
                title: localization.text("mode.daily_wish"),
                symbol: "moon.stars.fill",
                tint: PastelPalette.butterYellow.swiftUIColor
            ) {
                haptics.tap(reduceMotion: reduceMotion)
                router.open(.dailyWish)
            }
            .accessibilityIdentifier("nav.dailyWish")

            ModePillButton(
                title: localization.text("mode.sticker_book"),
                symbol: "star.square.on.square.fill",
                tint: PastelPalette.lavender.swiftUIColor
            ) {
                haptics.tap(reduceMotion: reduceMotion)
                router.open(.stickerBook)
            }
            .accessibilityIdentifier("nav.stickerBook")
        }
    }
}

private struct AreaTileModel: Identifiable {
    let destination: AppDestination
    let titleKey: String
    let descKey: String
    let tint: CodableColor
    let accent: CodableColor
    let symbol: String
    let accessibilityId: String

    var id: String { destination.rawValue }
}

private struct AreaCardButton: View {
    let title: String
    let subtitle: String
    let tint: Color
    let accent: Color
    let symbol: String
    let compactPhone: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: compactPhone ? 9 : 12) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.85))
                        .frame(width: compactPhone ? 40 : 48, height: compactPhone ? 40 : 48)
                    Image(systemName: symbol)
                        .font(.system(size: compactPhone ? 18 : 21, weight: .bold))
                        .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(compactPhone ? .subheadline : .headline, design: .rounded).weight(.heavy))
                        .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Text(subtitle)
                        .font(.system(.caption, design: .rounded).weight(.medium))
                        .foregroundStyle(PastelPalette.mutedText.swiftUIColor)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)
            }
            .padding(compactPhone ? 10 : 14)
            .frame(maxWidth: .infinity, minHeight: compactPhone ? 74 : 92, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.white.opacity(0.90))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(accent.opacity(0.35), lineWidth: 2)
                    )
                    .shadow(color: accent.opacity(0.14), radius: 8, y: 4)
            )
        }
        .accessibilityLabel("\(title). \(subtitle)")
    }
}

private struct ModePillButton: View {
    let title: String
    let symbol: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .bold))
                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(PastelPalette.inkText.swiftUIColor)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                Capsule()
                    .fill(tint.opacity(0.85))
                    .overlay(Capsule().stroke(.white.opacity(0.9), lineWidth: 1.5))
                    .shadow(color: PastelPalette.lavenderDeep.swiftUIColor.opacity(0.12), radius: 5, y: 3)
            )
        }
        .accessibilityLabel(title)
    }
}
