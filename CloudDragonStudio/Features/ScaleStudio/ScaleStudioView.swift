import CoreGraphics
import SwiftUI

struct ScaleStudioView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var localization: LocalizationService
    @EnvironmentObject private var haptics: HapticsService
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    @State private var selectedZone: DragonZone = .scales
    @State private var selectedTool: PaintToolKind = .solid
    @State private var selectedColor: CodableColor = PastelPalette.coralBlush
    @State private var hueValue: Double = 0.94
    @State private var brushWidthNormalized: CGFloat = 0.055
    @State private var activeStrokePoints: [CodablePoint] = []
    @State private var showHint = true

    private var reduceMotion: Bool {
        container.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height

            ZStack {
                CloudBackdropView(reduceMotion: reduceMotion)

                VStack(spacing: 8) {
                    TopNavBar(
                        title: localization.text("area.scale"),
                        backLabel: localization.text("nav.home"),
                        onBack: { router.popToHome() },
                        trailingContent: AnyView(undoRedoClearBar)
                    )

                    if isLandscape {
                        HStack(spacing: 16) {
                            canvasStage
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            toolDock(compact: false)
                                .frame(width: min(360, geo.size.width * 0.40))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    } else {
                        VStack(spacing: 10) {
                            canvasStage
                                .frame(maxWidth: .infinity, maxHeight: geo.size.height * 0.45)
                            toolDock(compact: true)
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 12)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var undoRedoClearBar: some View {
        HStack(spacing: 8) {
            studioActionButton(
                symbol: "arrow.uturn.backward",
                label: localization.text("scale.undo"),
                enabled: container.paintHistory.canUndo,
                id: "scale.undo"
            ) {
                haptics.tap(reduceMotion: reduceMotion)
                container.undoPaint()
            }

            studioActionButton(
                symbol: "arrow.uturn.forward",
                label: localization.text("scale.redo"),
                enabled: container.paintHistory.canRedo,
                id: "scale.redo"
            ) {
                haptics.tap(reduceMotion: reduceMotion)
                container.redoPaint()
            }

            studioActionButton(
                symbol: "trash.fill",
                label: localization.text("scale.clear"),
                enabled: !container.paintHistory.currentStrokes.isEmpty,
                id: "scale.clear"
            ) {
                haptics.tap(reduceMotion: reduceMotion)
                container.clearPaint()
            }
        }
    }

    private func studioActionButton(
        symbol: String,
        label: String,
        enabled: Bool,
        id: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(PastelPalette.inkText.swiftUIColor.opacity(enabled ? 1.0 : 0.35))
                .frame(minWidth: 44, minHeight: 44)
                .background(
                    Circle()
                        .fill(.white.opacity(enabled ? 0.94 : 0.55))
                        .shadow(color: PastelPalette.lavenderDeep.swiftUIColor.opacity(0.14), radius: 5, y: 2)
                )
        }
        .disabled(!enabled)
        .accessibilityIdentifier(id)
        .accessibilityLabel(label)
    }

    private var canvasStage: some View {
        GeometryReader { stageGeo in
            let side = min(stageGeo.size.width, stageGeo.size.height)
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.white.opacity(0.76))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(.white.opacity(0.95), lineWidth: 2)
                    )
                    .shadow(color: PastelPalette.lavenderDeep.swiftUIColor.opacity(0.15), radius: 12, y: 5)

                ZStack {
                    DragonView(
                        character: container.character,
                        reduceMotion: reduceMotion,
                        zonePaintImages: mergedLiveZoneImages,
                        highlightedZone: selectedZone,
                        showSparkles: true,
                        showPedestal: true,
                        animateIdle: false
                    )
                    .frame(width: side, height: side)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if showHint {
                                    showHint = false
                                }
                                let nx = min(max(value.location.x / max(side, 1), 0), 1)
                                let ny = min(max(value.location.y / max(side, 1), 0), 1)
                                let pt = CodablePoint(x: nx, y: ny)
                                if let last = activeStrokePoints.last {
                                    if hypot(pt.x - last.x, pt.y - last.y) >= 0.006 {
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
            }
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
            let zoneStrokes = container.paintHistory.currentStrokes.filter { $0.zone == selectedZone } + [liveStroke]
            if let liveImage = MaskedBrushRenderer.renderImage(strokes: zoneStrokes, onlyZone: selectedZone) {
                base[selectedZone] = liveImage
            }
        }
        return base
    }

    private func toolDock(compact: Bool) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: compact ? 10 : 12) {
                // 1. Zone Selector
                zoneSelectorRow

                // 2. Brush & Stamp Selector (true visual previews)
                toolSelectorGrid

                // 3. Brush Size Selector
                brushSizeRow

                // 4. Color Swatches + Hue Slider
                colorPickerCard
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.white.opacity(0.84))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white, lineWidth: 1.5)
                    )
            )
        }
    }

    private var zoneSelectorRow: some View {
        HStack(spacing: 8) {
            ForEach(DragonZone.allCases) { zone in
                let isSelected = selectedZone == zone
                Button {
                    haptics.tap(reduceMotion: reduceMotion)
                    selectedZone = zone
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: zoneSymbol(for: zone))
                            .font(.system(size: 15, weight: .bold))
                        Text(localization.text("scale.zone.\(zone.rawValue)"))
                            .font(.system(.caption2, design: .rounded).weight(.bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(isSelected ? PastelPalette.mint.swiftUIColor : Color.white.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(isSelected ? PastelPalette.mintDeep.swiftUIColor : Color.clear, lineWidth: 2)
                            )
                    )
                }
                .accessibilityIdentifier("scale.zone.\(zone.rawValue)")
                .accessibilityLabel(localization.text("scale.zone.\(zone.rawValue)"))
            }
        }
    }

    private var toolSelectorGrid: some View {
        let cols = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)
        return LazyVGrid(columns: cols, spacing: 8) {
            ForEach(PaintToolKind.allCases) { tool in
                let isSelected = selectedTool == tool
                Button {
                    haptics.tap(reduceMotion: reduceMotion)
                    selectedTool = tool
                } label: {
                    VStack(spacing: 4) {
                        ToolPreviewBadge(tool: tool, color: selectedColor.swiftUIColor)
                            .frame(width: 28, height: 22)
                        Text(localization.text(tool.localizationKey))
                            .font(.system(.caption2, design: .rounded).weight(.bold))
                            .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(isSelected ? PastelPalette.lavender.swiftUIColor : Color.white.opacity(0.92))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(isSelected ? PastelPalette.lavenderDeep.swiftUIColor : Color.clear, lineWidth: 2)
                            )
                    )
                }
                .accessibilityIdentifier("scale.tool.\(tool.rawValue)")
                .accessibilityLabel(localization.text(tool.localizationKey))
            }
        }
    }

    private var brushSizeRow: some View {
        let sizes: [(label: String, width: CGFloat, dot: CGFloat)] = [
            ("S", 0.030, 8),
            ("M", 0.055, 14),
            ("L", 0.090, 20)
        ]
        return HStack(spacing: 10) {
            Text(localization.text("scale.size"))
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(PastelPalette.mutedText.swiftUIColor)

            ForEach(sizes, id: \.label) { item in
                let isSelected = abs(brushWidthNormalized - item.width) < 0.005
                Button {
                    haptics.tap(reduceMotion: reduceMotion)
                    brushWidthNormalized = item.width
                } label: {
                    Circle()
                        .fill(selectedColor.swiftUIColor)
                        .overlay(Circle().stroke(PastelPalette.inkText.swiftUIColor.opacity(0.25), lineWidth: 1))
                        .frame(width: item.dot, height: item.dot)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isSelected ? PastelPalette.butterYellow.swiftUIColor : Color.white.opacity(0.9))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(isSelected ? PastelPalette.butterGold.swiftUIColor : Color.clear, lineWidth: 2)
                                )
                        )
                }
                .accessibilityIdentifier("scale.size.\(item.label)")
                .accessibilityLabel("\(localization.text("scale.size")) \(item.label)")
            }
        }
    }

    private var colorPickerCard: some View {
        VStack(spacing: 8) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                ForEach(Array(PastelPalette.studioSwatches.enumerated()), id: \.offset) { idx, swatch in
                    let isSelected = selectedColor == swatch
                    Button {
                        haptics.tap(reduceMotion: reduceMotion)
                        selectedColor = swatch
                    } label: {
                        Circle()
                            .fill(swatch.swiftUIColor)
                            .overlay(
                                Circle()
                                    .stroke(isSelected ? PastelPalette.inkText.swiftUIColor : .white, lineWidth: isSelected ? 3 : 1.5)
                            )
                            .frame(width: 34, height: 34)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .accessibilityIdentifier("scale.swatch.\(idx)")
                    .accessibilityLabel("Color \(idx + 1)")
                }
            }

            HStack(spacing: 10) {
                Text(localization.text("scale.hue"))
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(PastelPalette.mutedText.swiftUIColor)

                Slider(
                    value: Binding(
                        get: { hueValue },
                        set: { newHue in
                            hueValue = newHue
                            selectedColor = selectedColor.shiftedHue(to: newHue)
                        }
                    ),
                    in: 0...1
                )
                .tint(selectedColor.swiftUIColor)
                .accessibilityIdentifier("scale.hueSlider")
                .accessibilityLabel(localization.text("scale.hue"))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.red.opacity(0.25), .yellow.opacity(0.25), .green.opacity(0.25), .cyan.opacity(0.25), .blue.opacity(0.25), .purple.opacity(0.25), .red.opacity(0.25)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
    }

    private func zoneSymbol(for zone: DragonZone) -> String {
        switch zone {
        case .scales: return "sparkles"
        case .horns: return "crown.fill"
        case .wings: return "wind"
        case .tail: return "wand.and.stars"
        }
    }
}

private struct ToolPreviewBadge: View {
    let tool: PaintToolKind
    let color: Color

    var body: some View {
        switch tool {
        case .solid:
            Capsule()
                .fill(color)
                .frame(width: 24, height: 10)
        case .rainbow:
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.pink, .yellow, .mint, .cyan, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 24, height: 10)
        case .dots:
            HStack(spacing: 3) {
                Circle().fill(color).frame(width: 7, height: 7)
                Circle().fill(color).frame(width: 5, height: 5).offset(y: -4)
                Circle().fill(color).frame(width: 7, height: 7)
            }
        case .stripes:
            HStack(spacing: 3) {
                Capsule().fill(color).frame(width: 3, height: 14).rotationEffect(.degrees(25))
                Capsule().fill(color).frame(width: 3, height: 14).rotationEffect(.degrees(25))
                Capsule().fill(color).frame(width: 3, height: 14).rotationEffect(.degrees(25))
            }
        case .stampStar:
            Image(systemName: "star.fill").font(.system(size: 16)).foregroundStyle(color)
        case .stampHeart:
            Image(systemName: "heart.fill").font(.system(size: 16)).foregroundStyle(color)
        case .stampMoon:
            Image(systemName: "moon.fill").font(.system(size: 16)).foregroundStyle(color)
        case .stampCloud:
            Image(systemName: "cloud.fill").font(.system(size: 16)).foregroundStyle(color)
        }
    }
}
