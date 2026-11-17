import CoreGraphics
import SwiftUI

struct ScaleStudioView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var localization: LocalizationService
    @EnvironmentObject private var haptics: HapticsService
    @EnvironmentObject private var audio: AudioService
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    @State private var selectedZone: DragonZone = .belly
    @State private var selectedTool: PaintToolKind = .solid
    @State private var selectedColor: CodableColor = PastelPalette.roseSoft
    @State private var brushWidthNormalized: CGFloat = 0.048
    @State private var activeStrokePoints: [CodablePoint] = []
    @State private var showResetConfirm = false
    @State private var showHint = true

    private var reduceMotion: Bool {
        container.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height

            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.937, green: 0.902, blue: 0.992), // #EFE6FD
                        Color(red: 0.863, green: 0.973, blue: 0.929), // #DCF8ED
                        Color(red: 1.0, green: 0.976, blue: 0.871)    // #FFF9DE
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 8) {
                    TopNavBar(
                        title: localization.text("area.scale"),
                        subtitle: localization.text("area.scale.desc"),
                        backLabel: localization.text("nav.home"),
                        onBack: { router.popToHome() }
                    )

                    partSelectorRow

                    if isLandscape {
                        HStack(spacing: 14) {
                            studioStageCard
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            VStack(spacing: 10) {
                                Spacer(minLength: 0)
                                undoRedoClearButtons
                                toolPaletteRow
                                brushSizeRow
                                ColorSelectorCard(selectedColor: $selectedColor) { _ in
                                    audio.playSparkle()
                                }
                                Spacer(minLength: 0)
                            }
                            .frame(width: min(390, geo.size.width * 0.43))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                    } else {
                        studioStageCard
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, 16)

                        VStack(spacing: 8) {
                            undoRedoClearButtons
                            toolPaletteRow
                            brushSizeRow
                            ColorSelectorCard(selectedColor: $selectedColor) { _ in
                                audio.playSparkle()
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 10)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert(localization.text("scale.clear"), isPresented: $showResetConfirm) {
            Button(localization.text("nav.back"), role: .cancel) {}
            Button(localization.text("scale.clear"), role: .destructive) {
                audio.playPop()
                container.clearPaint(zone: selectedZone)
            }
        } message: {
            Text(localization.text("scale.clear_confirm"))
        }
    }

    private var undoRedoClearButtons: some View {
        HStack(spacing: 8) {
            let canUndo = container.character.canUndo(zone: selectedZone)
            let canRedo = container.character.canRedo(zone: selectedZone)
            let hasStrokes = !container.character.strokes(for: selectedZone).isEmpty

            Button {
                haptics.tap(reduceMotion: reduceMotion)
                audio.playPop()
                container.undoPaint(zone: selectedZone)
            } label: {
                Label(localization.text("scale.undo"), systemImage: "arrow.uturn.backward")
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(PastelPalette.textDark.swiftUIColor.opacity(canUndo ? 1.0 : 0.35))
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Capsule().fill(PastelPalette.butterWarm.swiftUIColor).overlay(Capsule().stroke(.white, lineWidth: 1.5)))
            }
            .disabled(!canUndo)
            .accessibilityIdentifier("scale.undo")
            .accessibilityLabel(localization.text("scale.undo"))

            Button {
                haptics.tap(reduceMotion: reduceMotion)
                audio.playPop()
                container.redoPaint(zone: selectedZone)
            } label: {
                Label(localization.text("scale.redo"), systemImage: "arrow.uturn.forward")
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(PastelPalette.textDark.swiftUIColor.opacity(canRedo ? 1.0 : 0.35))
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Capsule().fill(PastelPalette.lavenderLight.swiftUIColor).overlay(Capsule().stroke(.white, lineWidth: 1.5)))
            }
            .disabled(!canRedo)
            .accessibilityIdentifier("scale.redo")
            .accessibilityLabel(localization.text("scale.redo"))

            Button {
                haptics.tap(reduceMotion: reduceMotion)
                showResetConfirm = true
            } label: {
                Label(localization.text("scale.clear"), systemImage: "arrow.clockwise")
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(PastelPalette.textDark.swiftUIColor.opacity(hasStrokes ? 1.0 : 0.35))
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(Capsule().fill(PastelPalette.roseLight.swiftUIColor).overlay(Capsule().stroke(.white, lineWidth: 1.5)))
            }
            .disabled(!hasStrokes)
            .accessibilityIdentifier("scale.clear")
            .accessibilityLabel(localization.text("scale.clear"))
        }
    }

    private var partSelectorRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(DragonZone.allCases) { zone in
                    let isSelected = selectedZone == zone
                    Button {
                        haptics.tap(reduceMotion: reduceMotion)
                        audio.playPop()
                        selectedZone = zone
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: zoneSymbol(for: zone))
                                .font(.system(size: 14, weight: .bold))
                            Text(localization.text(zone.localizationKey))
                                .font(.system(.subheadline, design: .rounded).weight(isSelected ? .heavy : .semibold))
                        }
                        .foregroundStyle(isSelected ? PastelPalette.textDark.swiftUIColor : PastelPalette.textMuted.swiftUIColor)
                        .padding(.horizontal, 14)
                        .frame(minHeight: 44)
                        .background(
                            Capsule()
                                .fill(isSelected ? PastelPalette.lavenderPurple.swiftUIColor : .white.opacity(0.92))
                                .overlay(Capsule().stroke(isSelected ? PastelPalette.lavenderDark.swiftUIColor : .white, lineWidth: isSelected ? 2.5 : 1.5))
                        )
                    }
                    .accessibilityIdentifier("scale.zone.\(zone.rawValue)")
                    .accessibilityLabel(localization.text(zone.localizationKey))
                }
            }
            .padding(.horizontal, 14)
        }
    }

    private var studioStageCard: some View {
        GeometryReader { stageGeo in
            let side = min(stageGeo.size.width, stageGeo.size.height)
            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.882, green: 0.961, blue: 0.996),
                                Color(red: 1.0, green: 0.992, blue: 0.906),
                                Color(red: 0.945, green: 0.973, blue: 0.914)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(PastelPalette.butterYellow.swiftUIColor, lineWidth: 4)
                    )
                    .shadow(color: PastelPalette.lavenderDark.swiftUIColor.opacity(0.22), radius: 16, y: 6)

                // Festive studio bunting + cloud mat matching ADR 02_scale_studio.png
                VStack {
                    HStack {
                        Image(systemName: "flag.fill").foregroundStyle(PastelPalette.roseSoft.swiftUIColor)
                        Spacer()
                        Image(systemName: "sparkles").foregroundStyle(PastelPalette.butterDark.swiftUIColor)
                        Spacer()
                        Image(systemName: "gift.fill").foregroundStyle(PastelPalette.roseDark.swiftUIColor)
                        Spacer()
                        Image(systemName: "star.fill").foregroundStyle(PastelPalette.butterYellow.swiftUIColor)
                        Spacer()
                        Image(systemName: "flag.fill").foregroundStyle(PastelPalette.roseSoft.swiftUIColor)
                    }
                    .font(.system(size: 16, weight: .bold))
                    .padding(.horizontal, 22)
                    .padding(.top, 14)

                    Spacer()

                    Capsule()
                        .fill(PastelPalette.butterYellow.swiftUIColor.opacity(0.55))
                        .overlay(Capsule().stroke(.white, lineWidth: 2))
                        .frame(height: 28)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 18)
                }

                DragonView(
                    character: container.character,
                    reduceMotion: reduceMotion,
                    catalog: container.catalog,
                    zonePaintImages: mergedLiveZoneImages,
                    highlightedZone: selectedZone,
                    showSparkles: true,
                    animateIdle: false
                )
                .frame(width: side * 0.94, height: side * 0.94)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if showHint { showHint = false }
                            let canvasSide = max(side * 0.94, 1)
                            let nx = min(max(value.location.x / canvasSide, 0), 1)
                            let ny = min(max(value.location.y / canvasSide, 0), 1)
                            let pt = CodablePoint(x: nx, y: ny)
                            if let last = activeStrokePoints.last {
                                if hypot(pt.x - last.x, pt.y - last.y) >= 0.005 {
                                    activeStrokePoints.append(pt)
                                }
                            } else {
                                activeStrokePoints.append(pt)
                            }
                        }
                        .onEnded { _ in
                            if !activeStrokePoints.isEmpty {
                                let stroke = PaintStroke(
                                    zone: selectedZone,
                                    tool: selectedTool,
                                    color: selectedColor,
                                    brushWidthNormalized: brushWidthNormalized,
                                    normalizedPoints: activeStrokePoints
                                )
                                container.commitPaintStroke(stroke)
                                audio.playBrush()
                                haptics.sparkle(reduceMotion: reduceMotion)
                            }
                            activeStrokePoints = []
                        }
                )
                .accessibilityIdentifier("scale.canvas")
                .accessibilityLabel(localization.text("area.scale"))

                if showHint {
                    HandHintOverlay(
                        message: localization.text("scale.hint"),
                        reduceMotion: reduceMotion
                    )
                }
            }
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var mergedLiveZoneImages: [DragonZone: CGImage] {
        var base = container.zonePaintImages
        if !activeStrokePoints.isEmpty {
            let liveStroke = PaintStroke(
                zone: selectedZone,
                tool: selectedTool,
                color: selectedColor,
                brushWidthNormalized: brushWidthNormalized,
                normalizedPoints: activeStrokePoints
            )
            let combined = container.character.strokes(for: selectedZone) + [liveStroke]
            if let liveImg = MaskedBrushRenderer.renderImage(strokes: combined, onlyZone: selectedZone) {
                base[selectedZone] = liveImg
            }
        }
        return base
    }

    private var toolPaletteRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PaintToolKind.allCases) { tool in
                    let isSelected = selectedTool == tool
                    Button {
                        haptics.tap(reduceMotion: reduceMotion)
                        audio.playPop()
                        selectedTool = tool
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: toolSymbol(for: tool))
                                .font(.system(size: 18, weight: .bold))
                            Text(localization.text(tool.localizationKey))
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .lineLimit(1)
                        }
                        .foregroundStyle(isSelected ? PastelPalette.textDark.swiftUIColor : PastelPalette.textMuted.swiftUIColor)
                        .frame(width: 54, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(isSelected ? PastelPalette.mintGreen.swiftUIColor : .clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(isSelected ? .white : .clear, lineWidth: 2)
                                )
                        )
                    }
                    .accessibilityIdentifier("scale.tool.\(tool.rawValue)")
                    .accessibilityLabel(localization.text(tool.localizationKey))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(PastelPalette.cloudWhite.swiftUIColor.opacity(0.95))
                .shadow(color: Color.black.opacity(0.05), radius: 6, y: 2)
        )
    }

    private var brushSizeRow: some View {
        let sizes: [(id: String, width: CGFloat, dot: CGFloat)] = [
            ("S", 0.026, 8),
            ("M", 0.048, 14),
            ("L", 0.082, 20)
        ]
        return HStack(spacing: 8) {
            Text(localization.text("scale.size"))
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(PastelPalette.textMuted.swiftUIColor)

            ForEach(sizes, id: \.id) { sz in
                let isSelected = abs(brushWidthNormalized - sz.width) < 0.005
                Button {
                    haptics.tap(reduceMotion: reduceMotion)
                    brushWidthNormalized = sz.width
                } label: {
                    Circle()
                        .fill(selectedColor.swiftUIColor)
                        .overlay(Circle().stroke(PastelPalette.textDark.swiftUIColor.opacity(0.25), lineWidth: 1))
                        .frame(width: sz.dot, height: sz.dot)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isSelected ? PastelPalette.butterYellow.swiftUIColor : .white.opacity(0.9))
                        )
                }
                .accessibilityIdentifier("scale.size.\(sz.id)")
                .accessibilityLabel("\(localization.text("scale.size")) \(sz.id)")
            }
        }
    }

    private func zoneSymbol(for zone: DragonZone) -> String {
        switch zone {
        case .belly: return "sparkles"
        case .wings: return "wand.and.stars"
        case .horns: return "crown.fill"
        case .body: return "pawprint.fill"
        case .tail: return "cloud.fill"
        }
    }

    private func toolSymbol(for tool: PaintToolKind) -> String {
        switch tool {
        case .solid: return "paintbrush.pointed.fill"
        case .gradient: return "circle.lefthalf.filled"
        case .rainbow: return "rainbow"
        case .dots: return "circle.grid.3x3.fill"
        case .stampStar: return "star.fill"
        case .stampCloud: return "cloud.fill"
        case .stampHeart: return "heart.fill"
        case .eraser: return "eraser.fill"
        }
    }
}
