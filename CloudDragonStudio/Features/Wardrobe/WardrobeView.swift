import SwiftUI

struct WardrobeView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var localization: LocalizationService
    @EnvironmentObject private var haptics: HapticsService
    @EnvironmentObject private var audio: AudioService
    @EnvironmentObject private var purchases: PurchaseService
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    @State private var activeCategory: ItemCategory = .hat
    @State private var selectedItemColor: CodableColor = PastelPalette.butterYellow
    @State private var pendingPremiumItem: CatalogItem?
    @State private var showParentGate = false
    @State private var showPremiumPrompt = false

    private var reduceMotion: Bool {
        container.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height

            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.933, blue: 0.953),   // #FFEEF3
                        Color(red: 0.929, green: 0.906, blue: 0.965), // #EDE7F6
                        Color(red: 1.0, green: 0.976, blue: 0.769)    // #FFF9C4
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 8) {
                    TopNavBar(
                        title: localization.text("area.wardrobe"),
                        subtitle: localization.text("area.wardrobe.desc"),
                        backLabel: localization.text("nav.home"),
                        onBack: { router.popToHome() }
                    )

                    categoryTabsRow

                    if isLandscape {
                        HStack(spacing: 14) {
                            dressingRoomStage
                                .frame(maxWidth: .infinity, maxHeight: .infinity)

                            VStack(spacing: 10) {
                                Spacer(minLength: 0)
                                itemShelfRow
                                ColorSelectorCard(selectedColor: $selectedItemColor) { newColor in
                                    applyColorToEquipped(newColor)
                                }
                                Spacer(minLength: 0)
                            }
                            .frame(width: min(410, geo.size.width * 0.45))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    } else {
                        dressingRoomStage
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, 16)

                        itemShelfRow
                        ColorSelectorCard(selectedColor: $selectedItemColor) { newColor in
                            applyColorToEquipped(newColor)
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 12)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showParentGate) {
            ParentalGateSheet(
                onPassed: {
                    showParentGate = false
                    showPremiumPrompt = true
                },
                onCancel: {
                    showParentGate = false
                    pendingPremiumItem = nil
                }
            )
            .presentationDetents([.medium])
        }
        .alert(localization.text("premium.title"), isPresented: $showPremiumPrompt) {
            Button(localization.text("premium.buy_button")) {
                Task {
                    let ok = await purchases.purchasePremium()
                    if ok {
                        container.unlockPremiumLocally()
                        if let pendingPremiumItem {
                            container.equipItem(pendingPremiumItem, color: selectedItemColor)
                        }
                        pendingPremiumItem = nil
                    }
                }
            }
            if let item = pendingPremiumItem {
                Button(localization.text("premium.reward_unlock")) {
                    container.ads.presentOptionalRewardedExtra {
                        container.unlockRewardItem(item.id)
                        container.equipItem(item, color: selectedItemColor)
                        pendingPremiumItem = nil
                    }
                }
            }
            Button(localization.text("nav.back"), role: .cancel) {
                pendingPremiumItem = nil
            }
        } message: {
            Text(localization.text("premium.desc"))
        }
    }

    private var categoryTabsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ItemCategory.allCases) { cat in
                    let isSelected = activeCategory == cat
                    Button {
                        haptics.tap(reduceMotion: reduceMotion)
                        audio.playPop()
                        activeCategory = cat
                        if let eqId = container.character.equippedItems[cat.rawValue],
                           let item = container.catalog.first(where: { $0.id == eqId }) {
                            selectedItemColor = container.character.equippedColors[eqId] ?? item.defaultColor
                        }
                    } label: {
                        Text(localization.text(cat.localizationKey))
                            .font(.system(.subheadline, design: .rounded).weight(isSelected ? .heavy : .semibold))
                            .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                            .padding(.horizontal, 14)
                            .frame(minHeight: 44)
                            .background(
                                Capsule()
                                    .fill(isSelected ? categoryTint(cat) : .white.opacity(0.92))
                                    .overlay(Capsule().stroke(isSelected ? PastelPalette.textDark.swiftUIColor : PastelPalette.cardBorder.swiftUIColor, lineWidth: isSelected ? 2.5 : 1.5))
                            )
                    }
                    .accessibilityIdentifier("wardrobe.cat.\(cat.rawValue)")
                }
            }
            .padding(.horizontal, 14)
        }
    }

    private var dressingRoomStage: some View {
        GeometryReader { stageGeo in
            let side = min(stageGeo.size.width, stageGeo.size.height)
            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.941, blue: 0.961),
                                Color(red: 0.910, green: 0.961, blue: 0.914),
                                Color(red: 1.0, green: 0.992, blue: 0.906)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(PastelPalette.roseSoft.swiftUIColor, lineWidth: 4)
                    )
                    .shadow(color: PastelPalette.roseDark.swiftUIColor.opacity(0.20), radius: 16, y: 6)

                VStack {
                    HStack {
                        Image(systemName: "sparkles").foregroundStyle(PastelPalette.butterDark.swiftUIColor)
                        Spacer()
                        Image(systemName: "wand.and.stars").foregroundStyle(PastelPalette.lavenderDark.swiftUIColor)
                    }
                    .font(.system(size: 20, weight: .bold))
                    .padding(.horizontal, 26)
                    .padding(.top, 18)

                    Spacer()

                    Capsule()
                        .fill(PastelPalette.roseSoft.swiftUIColor.opacity(0.55))
                        .overlay(Capsule().stroke(.white, lineWidth: 2.5))
                        .frame(height: 30)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 18)
                }

                DragonView(
                    character: container.character,
                    reduceMotion: reduceMotion,
                    catalog: container.catalog,
                    zonePaintImages: container.zonePaintImages
                )
                .frame(width: side * 0.92, height: side * 0.92)
            }
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var itemShelfRow: some View {
        let items = container.catalog.filter { $0.category == activeCategory }
        let equippedId = container.character.equippedItems[activeCategory.rawValue]

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // None / Unequip card
                let isNone = equippedId == nil
                Button {
                    haptics.tap(reduceMotion: reduceMotion)
                    audio.playPop()
                    container.unequipCategory(activeCategory)
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: "nosign")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(isNone ? PastelPalette.roseDark.swiftUIColor : PastelPalette.textMuted.swiftUIColor)
                        Text(localization.text("wardrobe.none"))
                            .font(.system(.caption, design: .rounded).weight(.bold))
                            .foregroundStyle(isNone ? PastelPalette.roseDark.swiftUIColor : PastelPalette.textDark.swiftUIColor)
                            .lineLimit(1)
                    }
                    .frame(width: 86, height: 102)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(isNone ? PastelPalette.roseLight.swiftUIColor : Color(red: 1.0, green: 0.976, blue: 0.902))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(isNone ? PastelPalette.roseDark.swiftUIColor : PastelPalette.cardBorder.swiftUIColor, lineWidth: isNone ? 3 : 2)
                            )
                    )
                }
                .accessibilityIdentifier("wardrobe.item.none")

                ForEach(items) { item in
                    let isEquipped = equippedId == item.id
                    let unlocked = container.isItemUnlocked(item)
                    let displayColor = container.character.equippedColors[item.id] ?? item.defaultColor

                    Button {
                        haptics.tap(reduceMotion: reduceMotion)
                        if unlocked {
                            audio.playPop()
                            let colorToUse = container.character.equippedColors[item.id] ?? item.defaultColor
                            selectedItemColor = colorToUse
                            container.equipItem(item, color: colorToUse)
                        } else {
                            audio.playPop()
                            pendingPremiumItem = item
                            showParentGate = true
                        }
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            VStack(spacing: 4) {
                                ItemThumbnailCanvas(item: item, color: displayColor)
                                    .frame(width: 56, height: 56)

                                Text(item.localizedName(for: localization.language))
                                    .font(.system(.caption2, design: .rounded).weight(.bold))
                                    .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                                    .padding(.horizontal, 4)
                            }
                            .frame(width: 94, height: 102)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(isEquipped ? PastelPalette.butterYellow.swiftUIColor : Color(red: 1.0, green: 0.976, blue: 0.902))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(isEquipped ? PastelPalette.butterDark.swiftUIColor : PastelPalette.cardBorder.swiftUIColor, lineWidth: isEquipped ? 3.5 : 2)
                                    )
                            )

                            if isEquipped {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(PastelPalette.butterDark.swiftUIColor)
                                    .background(Circle().fill(.white))
                                    .padding(6)
                            } else if !unlocked {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(5)
                                    .background(Circle().fill(PastelPalette.lavenderDark.swiftUIColor))
                                    .padding(6)
                            }
                        }
                    }
                    .accessibilityIdentifier("wardrobe.item.\(item.id)")
                    .accessibilityLabel(item.localizedName(for: localization.language))
                }
            }
            .padding(.horizontal, 14)
        }
    }

    private func applyColorToEquipped(_ newColor: CodableColor) {
        audio.playSparkle()
        if let equippedId = container.character.equippedItems[activeCategory.rawValue] {
            container.setItemColor(newColor, for: equippedId)
        }
    }

    private func categoryTint(_ cat: ItemCategory) -> Color {
        switch cat {
        case .hat: return PastelPalette.butterYellow.swiftUIColor
        case .robe: return PastelPalette.skyBlue.swiftUIColor
        case .scarf: return PastelPalette.roseSoft.swiftUIColor
        case .glasses: return PastelPalette.mintGreen.swiftUIColor
        case .wingsDeco: return PastelPalette.lavenderPurple.swiftUIColor
        }
    }
}
