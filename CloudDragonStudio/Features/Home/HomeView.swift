import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var localization: LocalizationService
    @EnvironmentObject private var haptics: HapticsService
    @EnvironmentObject private var audio: AudioService
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    @State private var showParentGateForSettings = false

    private var reduceMotion: Bool {
        container.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            let isPadLike = geo.size.width >= 700

            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.878, green: 0.949, blue: 0.996), // #E0F2FE
                        Color(red: 0.929, green: 0.906, blue: 0.965), // #EDE7F6
                        Color(red: 0.996, green: 0.953, blue: 0.780)  // #FEF3C7
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 10) {
                    hubHeaderBar

                    if isLandscape {
                        HStack(spacing: 18) {
                            VStack(spacing: 12) {
                                modesRow
                                characterCard
                                    .frame(maxHeight: .infinity)
                            }
                            .frame(maxWidth: isPadLike ? 430 : geo.size.width * 0.44)

                            areasGrid(columnsCount: isPadLike ? 3 : 2)
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 14)
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 12) {
                                modesRow
                                characterCard
                                areasGrid(columnsCount: 2)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showParentGateForSettings) {
            ParentalGateSheet(
                onPassed: {
                    showParentGateForSettings = false
                    router.open(.settings)
                },
                onCancel: {
                    showParentGateForSettings = false
                }
            )
            .presentationDetents([.medium])
        }
    }

    private var hubHeaderBar: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(localization.text("app.title"))
                    .font(.system(.title3, design: .rounded).weight(.heavy))
                    .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(localization.text("app.subtitle"))
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(PastelPalette.textMuted.swiftUIColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer(minLength: 4)

            // Sound toggle button matching ADR green circle
            Button {
                haptics.tap(reduceMotion: reduceMotion)
                audio.toggleSound()
            } label: {
                Image(systemName: audio.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                    .frame(width: 46, height: 46)
                    .background(
                        Circle()
                            .fill(audio.isSoundEnabled ? PastelPalette.mintGreen.swiftUIColor : PastelPalette.cardBorder.swiftUIColor)
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                            .shadow(color: Color.black.opacity(0.08), radius: 4, y: 2)
                    )
            }
            .accessibilityIdentifier("nav.soundToggle")
            .accessibilityLabel(localization.text(audio.isSoundEnabled ? "nav.sound_on" : "nav.sound_off"))

            // Language toggle pill matching ADR lavender pill
            Button {
                haptics.tap(reduceMotion: reduceMotion)
                audio.playPop()
                localization.language = (localization.language == .en) ? .vi : .en
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "globe")
                        .font(.system(size: 15, weight: .bold))
                    Text(localization.language == .en ? "EN" : "VI")
                        .font(.system(.subheadline, design: .rounded).weight(.heavy))
                }
                .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                .padding(.horizontal, 12)
                .frame(minWidth: 66, minHeight: 46)
                .background(
                    Capsule()
                        .fill(PastelPalette.lavenderPurple.swiftUIColor)
                        .overlay(Capsule().stroke(.white, lineWidth: 2))
                        .shadow(color: Color.black.opacity(0.08), radius: 4, y: 2)
                )
            }
            .accessibilityIdentifier("nav.langToggle")
            .accessibilityLabel(localization.text("settings.language"))

            // Parental Gate / Settings Shield button matching ADR
            Button {
                haptics.tap(reduceMotion: reduceMotion)
                audio.playPop()
                showParentGateForSettings = true
            } label: {
                Image(systemName: "shield.fill")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(PastelPalette.strokeSoft.swiftUIColor)
                    .frame(width: 46, height: 46)
                    .background(
                        Circle()
                            .fill(PastelPalette.cloudWhite.swiftUIColor)
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                            .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
                    )
            }
            .accessibilityIdentifier("nav.settings")
            .accessibilityLabel(localization.text("mode.settings"))
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    private var modesRow: some View {
        HStack(spacing: 8) {
            HubModeCard(
                title: localization.text("mode.free_studio"),
                badge: "\(container.activeSlotIndex + 1)/12",
                symbol: "sparkles",
                colors: [Color(red: 0.863, green: 0.988, blue: 0.906), Color(red: 0.733, green: 0.969, blue: 0.816)],
                border: PastelPalette.mintGreen.swiftUIColor
            ) {
                haptics.tap(reduceMotion: reduceMotion)
                audio.playPop()
                router.open(.freeStudio)
            }
            .accessibilityIdentifier("nav.freeStudio")

            HubModeCard(
                title: localization.text("mode.daily_wish"),
                badge: container.isDailyWishCompletedToday ? localization.text("mode.done_badge") : localization.text("mode.new_badge"),
                symbol: "heart.fill",
                colors: [Color(red: 0.996, green: 0.941, blue: 0.541), Color(red: 0.992, green: 0.878, blue: 0.278)],
                border: PastelPalette.butterDark.swiftUIColor
            ) {
                haptics.tap(reduceMotion: reduceMotion)
                audio.playPop()
                router.open(.dailyWish)
            }
            .accessibilityIdentifier("nav.dailyWish")

            HubModeCard(
                title: localization.text("mode.sticker_book"),
                badge: "\(container.saveData.collectedStickerIDs.count)",
                symbol: "book.closed.fill",
                colors: [Color(red: 0.914, green: 0.835, blue: 1.0), Color(red: 0.847, green: 0.706, blue: 0.996)],
                border: PastelPalette.lavenderDark.swiftUIColor
            ) {
                haptics.tap(reduceMotion: reduceMotion)
                audio.playPop()
                router.open(.stickerBook)
            }
            .accessibilityIdentifier("nav.stickerBook")
        }
    }

    private var characterCard: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 72, height: 72)
                        .overlay(Circle().stroke(PastelPalette.mintGreen.swiftUIColor, lineWidth: 2.5))
                        .shadow(color: PastelPalette.mintGreen.swiftUIColor.opacity(0.35), radius: 6, y: 2)

                    DragonView(
                        character: container.character,
                        reduceMotion: reduceMotion,
                        catalog: container.catalog,
                        zonePaintImages: container.zonePaintImages,
                        showSparkles: false,
                        animateIdle: false
                    )
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("\(container.character.name) ✨")
                        .font(.system(.title3, design: .rounded).weight(.black))
                        .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(localization.text("home.dragon_greeting"))
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(PastelPalette.textMuted.swiftUIColor)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                }

                Spacer(minLength: 0)
            }

            Button {
                haptics.tap(reduceMotion: reduceMotion)
                audio.playPop()
                container.navigateToArea(.scaleStudio)
            } label: {
                Text(localization.text("home.style_dragon"))
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(
                        Capsule()
                            .fill(PastelPalette.mintGreen.swiftUIColor)
                            .shadow(color: PastelPalette.mintDark.swiftUIColor.opacity(0.22), radius: 6, y: 3)
                    )
            }
            .accessibilityIdentifier("home.styleDragonButton")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.white, Color(red: 0.961, green: 0.910, blue: 1.0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(PastelPalette.butterYellow.swiftUIColor, lineWidth: 3)
                )
                .shadow(color: PastelPalette.lavenderDark.swiftUIColor.opacity(0.18), radius: 12, y: 4)
        )
    }

    private func areasGrid(columnsCount: Int) -> some View {
        let zones: [HubAreaModel] = [
            HubAreaModel(
                destination: .scaleStudio,
                titleKey: "area.scale",
                descKey: "area.scale.desc",
                symbol: "paintpalette.fill",
                iconTint: PastelPalette.roseSoft.swiftUIColor,
                colors: [Color(red: 0.910, green: 0.973, blue: 0.961), Color(red: 0.831, green: 0.929, blue: 0.855)],
                border: PastelPalette.mintGreen.swiftUIColor,
                id: "nav.scaleStudio"
            ),
            HubAreaModel(
                destination: .wardrobe,
                titleKey: "area.wardrobe",
                descKey: "area.wardrobe.desc",
                symbol: "crown.fill",
                iconTint: PastelPalette.butterDark.swiftUIColor,
                colors: [Color(red: 0.953, green: 0.898, blue: 0.961), Color(red: 0.882, green: 0.745, blue: 0.906)],
                border: PastelPalette.lavenderPurple.swiftUIColor,
                id: "nav.wardrobe"
            ),
            HubAreaModel(
                destination: .cloudBath,
                titleKey: "area.bath",
                descKey: "area.bath.desc",
                symbol: "bathtub.fill",
                iconTint: PastelPalette.skyDark.swiftUIColor,
                colors: [Color(red: 0.882, green: 0.961, blue: 0.996), Color(red: 0.702, green: 0.898, blue: 0.988)],
                border: PastelPalette.skyBlue.swiftUIColor,
                id: "nav.cloudBath"
            ),
            HubAreaModel(
                destination: .bakeNook,
                titleKey: "area.bake",
                descKey: "area.bake.desc",
                symbol: "birthday.cake.fill",
                iconTint: PastelPalette.roseDark.swiftUIColor,
                colors: [Color(red: 1.0, green: 0.992, blue: 0.906), Color(red: 1.0, green: 0.976, blue: 0.769)],
                border: PastelPalette.butterYellow.swiftUIColor,
                id: "nav.bakeNook"
            ),
            HubAreaModel(
                destination: .petGarden,
                titleKey: "area.pets",
                descKey: "area.pets.desc",
                symbol: "hare.fill",
                iconTint: PastelPalette.lavenderDark.swiftUIColor,
                colors: [Color(red: 0.910, green: 0.961, blue: 0.914), Color(red: 0.784, green: 0.902, blue: 0.788)],
                border: PastelPalette.mintDark.swiftUIColor,
                id: "nav.petGarden"
            ),
            HubAreaModel(
                destination: .photoBooth,
                titleKey: "area.photo",
                descKey: "area.photo.desc",
                symbol: "camera.fill",
                iconTint: PastelPalette.textDark.swiftUIColor,
                colors: [Color(red: 1.0, green: 0.922, blue: 0.933), Color(red: 1.0, green: 0.804, blue: 0.824)],
                border: PastelPalette.roseSoft.swiftUIColor,
                id: "nav.photoBooth"
            )
        ]

        let cols = Array(repeating: GridItem(.flexible(), spacing: 10), count: columnsCount)
        return LazyVGrid(columns: cols, spacing: 10) {
            ForEach(zones) { zone in
                Button {
                    haptics.tap(reduceMotion: reduceMotion)
                    audio.playPop()
                    container.navigateToArea(zone.destination)
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.white.opacity(0.92))
                                    .frame(width: 40, height: 40)
                                Image(systemName: zone.symbol)
                                    .font(.system(size: 19, weight: .bold))
                                    .foregroundStyle(zone.iconTint)
                            }
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(zone.border)
                        }

                        Spacer(minLength: 4)

                        Text(localization.text(zone.titleKey))
                            .font(.system(.subheadline, design: .rounded).weight(.heavy))
                            .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Text(localization.text(zone.descKey))
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .foregroundStyle(PastelPalette.textMuted.swiftUIColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(LinearGradient(colors: zone.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(zone.border, lineWidth: 2.5)
                            )
                            .shadow(color: zone.border.opacity(0.22), radius: 7, y: 3)
                    )
                }
                .accessibilityIdentifier(zone.accessibilityId)
                .accessibilityLabel("\(localization.text(zone.titleKey)). \(localization.text(zone.descKey))")
            }
        }
    }
}

private struct HubModeCard: View {
    let title: String
    let badge: String
    let symbol: String
    let colors: [Color]
    let border: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(PastelPalette.textDark.swiftUIColor)

                Text(title)
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(badge)
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.88))
                            .overlay(Capsule().stroke(.white, lineWidth: 1.5))
                    )
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 82)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(border, lineWidth: 2.5)
                    )
                    .shadow(color: border.opacity(0.25), radius: 6, y: 3)
            )
        }
        .accessibilityLabel("\(title) \(badge)")
    }
}

private struct HubAreaModel: Identifiable {
    let destination: AppDestination
    let titleKey: String
    let descKey: String
    let symbol: String
    let iconTint: Color
    let colors: [Color]
    let border: Color
    let accessibilityId: String

    var id: String { destination.rawValue }

    init(
        destination: AppDestination,
        titleKey: String,
        descKey: String,
        symbol: String,
        iconTint: Color,
        colors: [Color],
        border: Color,
        id: String
    ) {
        self.destination = destination
        self.titleKey = titleKey
        self.descKey = descKey
        self.symbol = symbol
        self.iconTint = iconTint
        self.colors = colors
        self.border = border
        self.accessibilityId = id
    }
}
