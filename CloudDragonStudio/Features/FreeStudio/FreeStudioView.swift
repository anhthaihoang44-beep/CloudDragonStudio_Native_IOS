import SwiftUI

struct FreeStudioView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var localization: LocalizationService
    @EnvironmentObject private var haptics: HapticsService
    @EnvironmentObject private var audio: AudioService
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    private var reduceMotion: Bool {
        container.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    var body: some View {
        GeometryReader { geo in
            let cols = geo.size.width > 650 ? 4 : 3
            ZStack {
                CloudBackdropView(reduceMotion: reduceMotion)

                VStack(spacing: 12) {
                    TopNavBar(
                        title: localization.text("mode.free_studio"),
                        subtitle: localization.text("slots.subtitle"),
                        backLabel: localization.text("nav.home"),
                        onBack: { router.popToHome() }
                    )

                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: cols), spacing: 12) {
                            ForEach(Array(container.saveData.characters.enumerated()), id: \.element.id) { index, slotDragon in
                                let isSelected = index == container.activeSlotIndex
                                Button {
                                    haptics.tap(reduceMotion: reduceMotion)
                                    audio.playPop()
                                    container.selectSlot(index)
                                    router.popToHome()
                                } label: {
                                    VStack(spacing: 6) {
                                        DragonView(
                                            character: slotDragon,
                                            reduceMotion: true,
                                            catalog: container.catalog,
                                            zonePaintImages: MaskedBrushRenderer.renderZoneImages(for: slotDragon, size: 160),
                                            showSparkles: false,
                                            animateIdle: false
                                        )
                                        .frame(width: 72, height: 72)

                                        Text("Slot \(index + 1)")
                                            .font(.system(.caption, design: .rounded).weight(.heavy))
                                            .foregroundStyle(PastelPalette.textDark.swiftUIColor)

                                        Text(slotDragon.name)
                                            .font(.system(.caption2, design: .rounded).weight(.semibold))
                                            .foregroundStyle(PastelPalette.textMuted.swiftUIColor)
                                            .lineLimit(1)
                                    }
                                    .padding(10)
                                    .frame(maxWidth: .infinity, minHeight: 128)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    colors: isSelected
                                                        ? [PastelPalette.mintGreen.swiftUIColor, PastelPalette.mintLight.swiftUIColor]
                                                        : [.white, Color(red: 0.941, green: 0.957, blue: 0.973)],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                    .stroke(isSelected ? PastelPalette.mintDark.swiftUIColor : PastelPalette.cardBorder.swiftUIColor, lineWidth: isSelected ? 3 : 2)
                                            )
                                    )
                                }
                                .accessibilityIdentifier("slots.item.\(index)")
                                .accessibilityLabel("Slot \(index + 1) \(slotDragon.name)")
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
