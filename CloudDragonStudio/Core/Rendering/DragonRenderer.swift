import SwiftUI

struct DragonView: View {
    let character: CloudDragonCharacter
    let reduceMotion: Bool
    var zonePaintImages: [DragonZone: CGImage] = [:]
    var highlightedZone: DragonZone? = nil
    var showSparkles: Bool = true
    var showPedestal: Bool = true
    var animateIdle: Bool = true

    @State private var breathing = false

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            ZStack {
                if showPedestal {
                    CloudPedestalShape()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.95), PastelPalette.skyMid.swiftUIColor.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: side * 0.78, height: side * 0.22)
                        .offset(y: side * 0.34)
                        .shadow(color: PastelPalette.lavenderDeep.swiftUIColor.opacity(0.18), radius: 12, y: 6)
                }

                ZStack {
                    // 1. Tail + Tail Paint
                    DragonTailShape()
                        .fill(character.tailColor.swiftUIColor)
                        .overlay(paintOverlay(for: .tail, size: side))
                        .overlay(zoneStroke(for: .tail, shape: DragonTailShape()))

                    // 2. Wings + Wings Paint
                    Group {
                        DragonWingShape(mirrored: false)
                            .fill(character.wingColor.swiftUIColor)
                        DragonWingShape(mirrored: true)
                            .fill(character.wingColor.swiftUIColor)
                    }
                    .overlay(paintOverlay(for: .wings, size: side))
                    .overlay(zoneStroke(for: .wings, shape: DragonWingShape(mirrored: false)))
                    .overlay(zoneStroke(for: .wings, shape: DragonWingShape(mirrored: true)))

                    // 3. Body + Scales Paint (under Belly)
                    DragonBodyShape()
                        .fill(character.bodyColor.swiftUIColor)
                        .overlay(paintOverlay(for: .scales, size: side).clipShape(DragonBodyShape()))
                        .overlay(zoneStroke(for: .scales, shape: DragonBodyShape()))

                    // Belly + soft stripes
                    DragonBellyShape()
                        .fill(character.bellyColor.swiftUIColor)
                    VStack(spacing: side * 0.03) {
                        Capsule().fill(.white.opacity(0.45)).frame(width: side * 0.14, height: side * 0.015)
                        Capsule().fill(.white.opacity(0.45)).frame(width: side * 0.17, height: side * 0.015)
                        Capsule().fill(.white.opacity(0.45)).frame(width: side * 0.14, height: side * 0.015)
                    }
                    .offset(y: side * 0.14)

                    // 4. Horns + Horns Paint
                    Group {
                        DragonHornShape(mirrored: false)
                            .fill(character.hornColor.swiftUIColor)
                        DragonHornShape(mirrored: true)
                            .fill(character.hornColor.swiftUIColor)
                    }
                    .overlay(paintOverlay(for: .horns, size: side))
                    .overlay(zoneStroke(for: .horns, shape: DragonHornShape(mirrored: false)))
                    .overlay(zoneStroke(for: .horns, shape: DragonHornShape(mirrored: true)))

                    // 5. Head + Scales Paint (under Face Details)
                    DragonHeadShape()
                        .fill(character.bodyColor.swiftUIColor)
                        .overlay(paintOverlay(for: .scales, size: side).clipShape(DragonHeadShape()))
                        .overlay(zoneStroke(for: .scales, shape: DragonHeadShape()))

                    // Forehead scale tufts
                    HStack(spacing: side * 0.025) {
                        Circle().fill(character.tailColor.swiftUIColor).frame(width: side * 0.04, height: side * 0.04)
                        Circle().fill(character.tailColor.swiftUIColor).frame(width: side * 0.055, height: side * 0.055)
                        Circle().fill(character.tailColor.swiftUIColor).frame(width: side * 0.04, height: side * 0.04)
                    }
                    .offset(y: -side * 0.28)

                    // Rosy Cheeks
                    HStack(spacing: side * 0.20) {
                        Ellipse()
                            .fill(PastelPalette.coralBlush.swiftUIColor.opacity(0.55))
                            .frame(width: side * 0.08, height: side * 0.05)
                        Ellipse()
                            .fill(PastelPalette.coralBlush.swiftUIColor.opacity(0.55))
                            .frame(width: side * 0.08, height: side * 0.05)
                    }
                    .offset(y: -side * 0.04)

                    // Sparkly Eyes
                    HStack(spacing: side * 0.14) {
                        DragonEyeView(size: side * 0.085)
                        DragonEyeView(size: side * 0.085)
                    }
                    .offset(y: -side * 0.12)

                    // Gentle Smile
                    DragonSmileShape()
                        .stroke(PastelPalette.inkText.swiftUIColor, style: StrokeStyle(lineWidth: max(2.5, side * 0.014), lineCap: .round))
                        .frame(width: side * 0.11, height: side * 0.045)
                        .offset(y: -side * 0.03)

                    // Cute Front Paws
                    HStack(spacing: side * 0.18) {
                        Capsule()
                            .fill(character.bodyColor.swiftUIColor)
                            .overlay(Capsule().stroke(PastelPalette.inkText.swiftUIColor.opacity(0.18), lineWidth: 1.5))
                            .frame(width: side * 0.11, height: side * 0.075)
                        Capsule()
                            .fill(character.bodyColor.swiftUIColor)
                            .overlay(Capsule().stroke(PastelPalette.inkText.swiftUIColor.opacity(0.18), lineWidth: 1.5))
                            .frame(width: side * 0.11, height: side * 0.075)
                    }
                    .offset(y: side * 0.24)
                }
                .frame(width: side, height: side)
                .scaleEffect((!animateIdle || reduceMotion) ? 1.0 : (breathing ? 1.02 : 0.99))
                .offset(y: (!animateIdle || reduceMotion) ? 0 : (breathing ? -4 : 2))
                .animation(
                    (!animateIdle || reduceMotion) ? nil : .easeInOut(duration: 2.2).repeatForever(autoreverses: true),
                    value: breathing
                )

                if showSparkles {
                    SparkleStarShape()
                        .fill(PastelPalette.butterGold.swiftUIColor)
                        .frame(width: side * 0.075, height: side * 0.075)
                        .offset(x: -side * 0.34, y: -side * 0.27)
                    SparkleStarShape()
                        .fill(.white)
                        .frame(width: side * 0.055, height: side * 0.055)
                        .offset(x: side * 0.35, y: -side * 0.22)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                if animateIdle && !reduceMotion {
                    breathing = true
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(character.name)
    }

    @ViewBuilder
    private func paintOverlay(for zone: DragonZone, size: CGFloat) -> some View {
        if let cgImg = zonePaintImages[zone] {
            Image(decorative: cgImg, scale: 1.0)
                .resizable()
                .interpolation(.high)
                .frame(width: size, height: size)
        }
    }

    @ViewBuilder
    private func zoneStroke<S: Shape>(for zone: DragonZone, shape: S) -> some View {
        if highlightedZone == zone {
            shape
                .stroke(
                    PastelPalette.lavenderDeep.swiftUIColor,
                    style: StrokeStyle(lineWidth: 3.2, lineCap: .round, dash: [7, 5])
                )
        } else {
            shape
                .stroke(PastelPalette.inkText.swiftUIColor.opacity(0.18), lineWidth: 2)
        }
    }
}

private struct DragonEyeView: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(PastelPalette.inkText.swiftUIColor)
                .frame(width: size, height: size)
            Circle()
                .fill(.white)
                .frame(width: size * 0.38, height: size * 0.38)
                .offset(x: -size * 0.15, y: -size * 0.16)
            Circle()
                .fill(.white.opacity(0.85))
                .frame(width: size * 0.18, height: size * 0.18)
                .offset(x: size * 0.16, y: size * 0.18)
        }
    }
}

// MARK: - Original Vector Shapes backed by shared DragonGeometry

struct CloudPedestalShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.addEllipse(in: CGRect(x: w * 0.04, y: h * 0.30, width: w * 0.34, height: h * 0.68))
        path.addEllipse(in: CGRect(x: w * 0.24, y: h * 0.05, width: w * 0.52, height: h * 0.90))
        path.addEllipse(in: CGRect(x: w * 0.62, y: h * 0.28, width: w * 0.34, height: h * 0.70))
        return path
    }
}

struct DragonBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path(DragonGeometry.bodyPath(in: rect))
    }
}

struct DragonBellyShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path(DragonGeometry.bellyPath(in: rect))
    }
}

struct DragonHeadShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path(DragonGeometry.headPath(in: rect))
    }
}

struct DragonHornShape: Shape {
    let mirrored: Bool

    func path(in rect: CGRect) -> Path {
        Path(DragonGeometry.hornPath(in: rect, mirrored: mirrored))
    }
}

struct DragonWingShape: Shape {
    let mirrored: Bool

    func path(in rect: CGRect) -> Path {
        Path(DragonGeometry.wingPath(in: rect, mirrored: mirrored))
    }
}

struct DragonTailShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path(DragonGeometry.tailPath(in: rect))
    }
}

struct DragonSmileShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.2))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.2),
            control: CGPoint(x: rect.midX, y: rect.maxY)
        )
        return path
    }
}

struct SparkleStarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX
        let cy = rect.midY
        let outer = min(rect.width, rect.height) * 0.5
        let inner = outer * 0.35
        for i in 0..<8 {
            let angle = Double(i) * .pi / 4.0
            let radius = (i % 2 == 0) ? outer : inner
            let pt = CGPoint(x: cx + CGFloat(cos(angle)) * radius, y: cy + CGFloat(sin(angle)) * radius)
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.closeSubpath()
        return path
    }
}
