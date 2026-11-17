import SwiftUI

enum CookieShapeKind: String, CaseIterable, Identifiable {
    case cloud
    case star
    case moon
    case heart
    case flower

    var id: String { rawValue }
}

private struct CookieSprinkle: Identifiable, Equatable {
    let id = UUID()
    let normalizedPoint: CGPoint
    let color: CodableColor
}

struct BakeNookView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var localization: LocalizationService
    @EnvironmentObject private var haptics: HapticsService
    @EnvironmentObject private var audio: AudioService
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    @State private var selectedShape: CookieShapeKind = .cloud
    @State private var icingColor: CodableColor = PastelPalette.butterWarm
    @State private var sprinkles: [CookieSprinkle] = []
    @State private var redoSprinkles: [CookieSprinkle] = []
    @State private var isOvenBaking = false
    @State private var isBaked = false
    @State private var isFeedingMode = false
    @State private var bitesCount = 0

    private let icingFlavors: [CodableColor] = [
        CodableColor(hex: 0xFFDD59),
        CodableColor(hex: 0xFF5E7E),
        CodableColor(hex: 0x2ED573),
        CodableColor(hex: 0xD980FA),
        CodableColor(hex: 0xFF9F43)
    ]

    private var reduceMotion: Bool {
        container.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height

            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.996, green: 0.953, blue: 0.780), // #FEF3C7
                        Color(red: 1.0, green: 0.929, blue: 0.835),   // #FFEDD5
                        Color(red: 0.988, green: 0.906, blue: 0.953)  // #FCE7F3
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 8) {
                    TopNavBar(
                        title: localization.text("area.bake"),
                        subtitle: localization.text("area.bake.desc"),
                        backLabel: localization.text("nav.home"),
                        onBack: { router.popToHome() },
                        trailingContent: isFeedingMode ? nil : AnyView(icingUndoRedoBar)
                    )

                    modeToggleRow

                    if !isFeedingMode {
                        shapePickerRow
                    }

                    if isLandscape {
                        HStack(spacing: 16) {
                            kitchenTrayStage
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            bakeControlsColumn
                                .frame(width: min(350, geo.size.width * 0.40))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    } else {
                        kitchenTrayStage
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, 16)
                        bakeControlsColumn
                            .padding(.horizontal, 16)
                            .padding(.bottom, 14)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var icingUndoRedoBar: some View {
        HStack(spacing: 6) {
            Button {
                if let removed = sprinkles.popLast() {
                    redoSprinkles.append(removed)
                    audio.playPop()
                }
            } label: {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(PastelPalette.textDark.swiftUIColor.opacity(sprinkles.isEmpty ? 0.35 : 1.0))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(.white.opacity(0.9)))
            }
            .disabled(sprinkles.isEmpty)
            .accessibilityIdentifier("bake.undo")

            Button {
                if let restored = redoSprinkles.popLast() {
                    sprinkles.append(restored)
                    audio.playPop()
                }
            } label: {
                Image(systemName: "arrow.uturn.forward")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(PastelPalette.textDark.swiftUIColor.opacity(redoSprinkles.isEmpty ? 0.35 : 1.0))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(.white.opacity(0.9)))
            }
            .disabled(redoSprinkles.isEmpty)
            .accessibilityIdentifier("bake.redo")
        }
    }

    private var modeToggleRow: some View {
        HStack(spacing: 10) {
            Button {
                haptics.tap(reduceMotion: reduceMotion)
                audio.playPop()
                isFeedingMode = false
            } label: {
                Label(localization.text("bake.decorate"), systemImage: "birthday.cake.fill")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(
                        Capsule()
                            .fill(!isFeedingMode ? PastelPalette.butterYellow.swiftUIColor : .white.opacity(0.9))
                            .overlay(Capsule().stroke(.white, lineWidth: 2))
                    )
            }
            .accessibilityIdentifier("bake.mode.decorate")

            Button {
                haptics.tap(reduceMotion: reduceMotion)
                if !isBaked {
                    audio.playPop()
                    return
                }
                audio.playCheer()
                isFeedingMode = true
                bitesCount = 0
                container.setExpression(.happy)
            } label: {
                Label(localization.text("bake.feed"), systemImage: "face.smiling.fill")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(PastelPalette.textDark.swiftUIColor.opacity(isBaked ? 1.0 : 0.55))
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(
                        Capsule()
                            .fill(isFeedingMode ? PastelPalette.mintGreen.swiftUIColor : .white.opacity(0.9))
                            .overlay(Capsule().stroke(.white, lineWidth: 2))
                    )
            }
            .accessibilityIdentifier("bake.mode.feed")
        }
        .padding(.horizontal, 16)
    }

    private var shapePickerRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CookieShapeKind.allCases) { shape in
                    let isSelected = selectedShape == shape
                    Button {
                        haptics.tap(reduceMotion: reduceMotion)
                        audio.playPop()
                        selectedShape = shape
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: symbol(for: shape))
                            Text(localization.text("bake.shape.\(shape.rawValue)"))
                                .font(.system(.subheadline, design: .rounded).weight(.bold))
                        }
                        .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                        .padding(.horizontal, 14)
                        .frame(minHeight: 44)
                        .background(
                            Capsule()
                                .fill(isSelected ? PastelPalette.butterYellow.swiftUIColor : .white.opacity(0.9))
                                .overlay(Capsule().stroke(isSelected ? PastelPalette.textDark.swiftUIColor : PastelPalette.cardBorder.swiftUIColor, lineWidth: isSelected ? 2.5 : 1.5))
                        )
                    }
                    .accessibilityIdentifier("bake.shape.\(shape.rawValue)")
                }
            }
            .padding(.horizontal, 14)
        }
    }

    private var kitchenTrayStage: some View {
        GeometryReader { stageGeo in
            let side = min(stageGeo.size.width, stageGeo.size.height)
            ZStack {
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.969, blue: 0.929),
                                Color(red: 1.0, green: 0.929, blue: 0.835),
                                Color(red: 0.996, green: 0.843, blue: 0.667)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 36, style: .continuous)
                            .stroke(PastelPalette.butterYellow.swiftUIColor, lineWidth: 4.5)
                    )
                    .shadow(color: PastelPalette.peachDark.swiftUIColor.opacity(0.24), radius: 16, y: 6)

                VStack {
                    HStack {
                        Image(systemName: "cup.and.saucer.fill")
                        Spacer()
                        Image(systemName: "sparkles")
                        Spacer()
                        Image(systemName: "birthday.cake.fill")
                    }
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(PastelPalette.peachDark.swiftUIColor.opacity(0.75))
                    .padding(.horizontal, 28)
                    .padding(.top, 16)

                    Spacer()

                    Capsule()
                        .fill(PastelPalette.butterWarm.swiftUIColor.opacity(0.7))
                        .overlay(Capsule().stroke(.white, lineWidth: 2))
                        .frame(height: 30)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 16)
                }

                if isFeedingMode {
                    VStack(spacing: 10) {
                        DragonView(
                            character: container.character,
                            reduceMotion: reduceMotion,
                            catalog: container.catalog,
                            zonePaintImages: container.zonePaintImages
                        )
                        .frame(width: side * 0.56, height: side * 0.56)

                        Button {
                            guard bitesCount < 3 else { return }
                            bitesCount += 1
                            audio.playCheer()
                            haptics.sparkle(reduceMotion: reduceMotion)
                            container.setExpression(.eating)
                            Task { @MainActor in
                                try? await Task.sleep(nanoseconds: 550_000_000)
                                container.setExpression(.delighted)
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.898, green: 0.698, blue: 0.490))
                                    .frame(width: 78, height: 78)
                                    .overlay(Circle().stroke(.white, lineWidth: 3.5))
                                Image(systemName: symbol(for: selectedShape))
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .scaleEffect(max(0.25, 1.0 - Double(bitesCount) * 0.25))
                            .animation(reduceMotion ? nil : .spring(response: 0.3), value: bitesCount)
                        }
                        .accessibilityIdentifier("bake.feedCookieButton")
                    }
                } else {
                    ZStack {
                        if isOvenBaking {
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .fill(Color.orange.opacity(0.28))
                            Text(localization.text("bake.baking_now"))
                                .font(.system(.title3, design: .rounded).weight(.heavy))
                                .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                        }

                        Circle()
                            .fill(isBaked ? Color(red: 0.898, green: 0.698, blue: 0.490) : icingColor.swiftUIColor)
                            .frame(width: side * 0.54, height: side * 0.54)
                            .overlay(Circle().stroke(.white, lineWidth: 4))
                            .shadow(color: Color.brown.opacity(0.2), radius: 12, y: 6)
                            .overlay(
                                Image(systemName: symbol(for: selectedShape))
                                    .font(.system(size: side * 0.25, weight: .bold))
                                    .foregroundStyle(isBaked ? Color(red: 0.553, green: 0.357, blue: 0.157) : .white.opacity(0.92))
                            )

                        ForEach(sprinkles) { sp in
                            Circle()
                                .fill(sp.color.swiftUIColor)
                                .overlay(Circle().stroke(.white, lineWidth: 1.5))
                                .frame(width: 16, height: 16)
                                .position(x: sp.normalizedPoint.x * side, y: sp.normalizedPoint.y * side)
                                .allowsHitTesting(false)
                        }
                    }
                    .frame(width: side, height: side)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                let nx = min(max(value.location.x / max(side, 1), 0.18), 0.82)
                                let ny = min(max(value.location.y / max(side, 1), 0.18), 0.82)
                                sprinkles.append(
                                    CookieSprinkle(
                                        normalizedPoint: CGPoint(x: nx, y: ny),
                                        color: icingColor
                                    )
                                )
                                redoSprinkles.removeAll()
                                audio.playSparkle()
                            }
                    )
                    .accessibilityIdentifier("bake.tray")
                }
            }
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private var bakeControlsColumn: some View {
        if !isFeedingMode {
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    Text(localization.text("bake.icing"))
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                    ForEach(Array(icingFlavors.enumerated()), id: \.offset) { idx, flavor in
                        let isSelected = icingColor == flavor
                        Button {
                            icingColor = flavor
                            audio.playSparkle()
                        } label: {
                            Circle()
                                .fill(flavor.swiftUIColor)
                                .frame(width: 38, height: 38)
                                .overlay(Circle().stroke(isSelected ? PastelPalette.textDark.swiftUIColor : .white, lineWidth: isSelected ? 3 : 2))
                                .frame(minWidth: 44, minHeight: 44)
                        }
                        .accessibilityIdentifier("bake.icing.\(idx)")
                    }
                }

                HStack(spacing: 10) {
                    Button {
                        guard !isOvenBaking else { return }
                        isOvenBaking = true
                        audio.playSparkle()
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 900_000_000)
                            isOvenBaking = false
                            isBaked = true
                            audio.playCheer()
                            container.collectSticker("sticker_baker_star")
                        }
                    } label: {
                        Label(
                            isOvenBaking
                                ? localization.text("bake.baking_now")
                                : (isBaked ? localization.text("bake.baked_fresh") : localization.text("bake.bake_btn")),
                            systemImage: "flame.fill"
                        )
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Capsule().fill(PastelPalette.mintGreen.swiftUIColor))
                    }
                    .accessibilityIdentifier("bake.ovenButton")

                    Button {
                        sprinkles.removeAll()
                        redoSprinkles.removeAll()
                        isBaked = false
                        bitesCount = 0
                        audio.playPop()
                    } label: {
                        Label(localization.text("scale.clear"), systemImage: "arrow.clockwise")
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .foregroundStyle(PastelPalette.textMuted.swiftUIColor)
                            .padding(.horizontal, 16)
                            .frame(minHeight: 48)
                            .background(Capsule().fill(.white.opacity(0.95)))
                    }
                    .accessibilityIdentifier("bake.resetButton")
                }
            }
        } else {
            Button {
                if bitesCount >= 3 {
                    isFeedingMode = false
                    isBaked = false
                    sprinkles.removeAll()
                    bitesCount = 0
                }
            } label: {
                Label(
                    bitesCount >= 3 ? localization.text("bake.full_dragon") : localization.text("bake.tap_to_feed"),
                    systemImage: "birthday.cake.fill"
                )
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Capsule().fill(PastelPalette.butterYellow.swiftUIColor))
            }
            .accessibilityIdentifier("bake.feedDoneButton")
        }
    }

    private func symbol(for shape: CookieShapeKind) -> String {
        switch shape {
        case .cloud: return "cloud.fill"
        case .star: return "star.fill"
        case .moon: return "moon.fill"
        case .heart: return "heart.fill"
        case .flower: return "camera.macro"
        }
    }
}
