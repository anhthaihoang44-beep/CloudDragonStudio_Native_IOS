import SwiftUI

enum BathTool: String, CaseIterable, Identifiable {
    case soap
    case shower
    case dryer
    case brush

    var id: String { rawValue }
}

private struct BathBubble: Identifiable {
    let id = UUID()
    var normalizedPoint: CGPoint
    var radius: CGFloat
    var tint: CodableColor
}

struct CloudBathView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var localization: LocalizationService
    @EnvironmentObject private var haptics: HapticsService
    @EnvironmentObject private var audio: AudioService
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    @State private var activeTool: BathTool = .soap
    @State private var bubbles: [BathBubble] = []
    @State private var sparklePoints: [CGPoint] = []
    @State private var cleanProgress: Double = 0.0
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
                        Color(red: 0.729, green: 0.902, blue: 0.992), // #BAE6FD
                        Color(red: 0.878, green: 0.949, blue: 0.996), // #E0F2FE
                        Color(red: 0.820, green: 0.980, blue: 0.898)  // #D1FAE5
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 8) {
                    TopNavBar(
                        title: localization.text("area.bath"),
                        subtitle: localization.text("area.bath.desc"),
                        backLabel: localization.text("nav.home"),
                        onBack: { router.popToHome() }
                    )

                    bathToolsRow

                    if isLandscape {
                        HStack(spacing: 16) {
                            bathTubStage
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            hintBanner
                                .frame(width: min(320, geo.size.width * 0.34))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    } else {
                        bathTubStage
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, 16)
                        hintBanner
                            .padding(.horizontal, 16)
                            .padding(.bottom, 14)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var bathToolsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(BathTool.allCases) { tool in
                    let isSelected = activeTool == tool
                    Button {
                        haptics.tap(reduceMotion: reduceMotion)
                        audio.playPop()
                        activeTool = tool
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: symbol(for: tool))
                                .font(.system(size: 15, weight: .bold))
                            Text(localization.text("bath.tool.\(tool.rawValue)"))
                                .font(.system(.subheadline, design: .rounded).weight(.bold))
                        }
                        .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                        .padding(.horizontal, 14)
                        .frame(minHeight: 46)
                        .background(
                            Capsule()
                                .fill(isSelected ? tint(for: tool) : .white.opacity(0.92))
                                .overlay(Capsule().stroke(.white, lineWidth: 2))
                                .shadow(color: Color.black.opacity(0.06), radius: 4, y: 2)
                        )
                    }
                    .accessibilityIdentifier("bath.tool.\(tool.rawValue)")
                }
            }
            .padding(.horizontal, 14)
        }
    }

    private var bathTubStage: some View {
        GeometryReader { stageGeo in
            let side = min(stageGeo.size.width, stageGeo.size.height)
            ZStack {
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.878, green: 0.969, blue: 0.980),
                                Color(red: 1.0, green: 0.976, blue: 0.769),
                                Color(red: 0.698, green: 0.922, blue: 0.949)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 36, style: .continuous)
                            .stroke(PastelPalette.skyBlue.swiftUIColor, lineWidth: 4.5)
                    )
                    .shadow(color: PastelPalette.skyDark.swiftUIColor.opacity(0.24), radius: 16, y: 6)

                // Cute tub decorations matching ADR 04_cloud_bath.png
                VStack {
                    HStack {
                        Image(systemName: "drop.circle.fill")
                            .foregroundStyle(PastelPalette.butterDark.swiftUIColor)
                        Spacer()
                        Image(systemName: "rainbow")
                            .foregroundStyle(PastelPalette.roseSoft.swiftUIColor)
                    }
                    .font(.system(size: 24, weight: .bold))
                    .padding(.horizontal, 24)
                    .padding(.top, 18)

                    Spacer()

                    HStack(spacing: 22) {
                        Image(systemName: "bubbles.and.sparkles.fill")
                        Image(systemName: "water.waves")
                        Image(systemName: "bubbles.and.sparkles.fill")
                        Image(systemName: "water.waves")
                        Image(systemName: "bubbles.and.sparkles.fill")
                    }
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(PastelPalette.skyDark.swiftUIColor.opacity(0.65))
                    .padding(.bottom, 16)
                }

                DragonView(
                    character: container.character,
                    reduceMotion: reduceMotion,
                    catalog: container.catalog,
                    zonePaintImages: container.zonePaintImages
                )
                .frame(width: side * 0.88, height: side * 0.88)

                // Sparkles from dryer/brush
                ForEach(Array(sparklePoints.enumerated()), id: \.offset) { _, pt in
                    Image(systemName: "sparkle")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(PastelPalette.butterDark.swiftUIColor)
                        .position(x: pt.x * side, y: pt.y * side)
                        .allowsHitTesting(false)
                }

                // Soap foam bubbles (tappable to pop!)
                ForEach(bubbles) { bubble in
                    Circle()
                        .fill(bubble.tint.swiftUIColor.opacity(0.65))
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                        .frame(width: bubble.radius * 2, height: bubble.radius * 2)
                        .position(x: bubble.normalizedPoint.x * side, y: bubble.normalizedPoint.y * side)
                        .onTapGesture {
                            bubbles.removeAll { $0.id == bubble.id }
                            audio.playPop()
                        }
                }

                if showHint {
                    HandHintOverlay(message: localization.text("bath.hint.\(activeTool.rawValue)"), reduceMotion: reduceMotion)
                }
            }
            .frame(width: side, height: side)
            .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if showHint { showHint = false }
                        let nx = min(max(value.location.x / max(side, 1), 0.05), 0.95)
                        let ny = min(max(value.location.y / max(side, 1), 0.05), 0.95)
                        let nPt = CGPoint(x: nx, y: ny)

                        switch activeTool {
                        case .soap:
                            if bubbles.count < 40 {
                                let jitter = CGPoint(
                                    x: nx + CGFloat.random(in: -0.04...0.04),
                                    y: ny + CGFloat.random(in: -0.04...0.04)
                                )
                                bubbles.append(
                                    BathBubble(
                                        normalizedPoint: jitter,
                                        radius: CGFloat.random(in: 14...28),
                                        tint: Bool.random() ? PastelPalette.roseSoft : PastelPalette.butterYellow
                                    )
                                )
                                audio.playPop()
                            }
                        case .shower:
                            bubbles.removeAll { hypot($0.normalizedPoint.x - nPt.x, $0.normalizedPoint.y - nPt.y) < 0.16 }
                            cleanProgress = min(1.0, cleanProgress + 0.05)
                            audio.playPop()
                        case .dryer:
                            if sparklePoints.count < 16 {
                                sparklePoints.append(nPt)
                                audio.playSparkle()
                            }
                        case .brush:
                            container.setExpression(.delighted)
                            container.collectSticker("sticker_clean_dragon")
                            audio.playCheer()
                        }
                    }
            )
            .accessibilityIdentifier("bath.stage")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var hintBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol(for: activeTool))
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(PastelPalette.skyDark.swiftUIColor)
            Text(localization.text("bath.hint.\(activeTool.rawValue)"))
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                .lineLimit(2)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.white.opacity(0.95))
                .shadow(color: Color.black.opacity(0.06), radius: 8, y: 3)
        )
    }

    private func symbol(for tool: BathTool) -> String {
        switch tool {
        case .soap: return "cloud.fill"
        case .shower: return "shower.fill"
        case .dryer: return "wind"
        case .brush: return "comb.fill"
        }
    }

    private func tint(for tool: BathTool) -> Color {
        switch tool {
        case .soap: return PastelPalette.butterYellow.swiftUIColor
        case .shower: return PastelPalette.mintGreen.swiftUIColor
        case .dryer: return PastelPalette.skyBlue.swiftUIColor
        case .brush: return PastelPalette.lavenderPurple.swiftUIColor
        }
    }
}
