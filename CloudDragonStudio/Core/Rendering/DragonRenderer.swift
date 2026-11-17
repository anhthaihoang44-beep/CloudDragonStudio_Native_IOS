import SwiftUI

struct DragonView: View {
    let character: CloudDragonCharacter
    let reduceMotion: Bool
    var showSparkles: Bool = true

    @State private var breathing = false

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            ZStack {
                // Soft pastel cloud pedestal beneath the dragon
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

                // Main layered baby cloud dragon
                ZStack {
                    // Tail
                    DragonTailShape()
                        .fill(character.tailColor.swiftUIColor)
                        .overlay(
                            DragonTailShape()
                                .stroke(PastelPalette.inkText.swiftUIColor.opacity(0.18), lineWidth: 2)
                        )

                    // Left & Right Wings
                    DragonWingShape(mirrored: false)
                        .fill(character.wingColor.swiftUIColor)
                        .overlay(
                            DragonWingShape(mirrored: false)
                                .stroke(PastelPalette.inkText.swiftUIColor.opacity(0.18), lineWidth: 2)
                        )
                    DragonWingShape(mirrored: true)
                        .fill(character.wingColor.swiftUIColor)
                        .overlay(
                            DragonWingShape(mirrored: true)
                                .stroke(PastelPalette.inkText.swiftUIColor.opacity(0.18), lineWidth: 2)
                        )

                    // Chubby Body
                    DragonBodyShape()
                        .fill(character.bodyColor.swiftUIColor)
                        .overlay(
                            DragonBodyShape()
                                .stroke(PastelPalette.inkText.swiftUIColor.opacity(0.18), lineWidth: 2)
                        )

                    // Belly
                    DragonBellyShape()
                        .fill(character.bellyColor.swiftUIColor)

                    // Belly scale stripes
                    VStack(spacing: side * 0.03) {
                        Capsule().fill(.white.opacity(0.45)).frame(width: side * 0.14, height: side * 0.015)
                        Capsule().fill(.white.opacity(0.45)).frame(width: side * 0.17, height: side * 0.015)
                        Capsule().fill(.white.opacity(0.45)).frame(width: side * 0.14, height: side * 0.015)
                    }
                    .offset(y: side * 0.14)

                    // Horns
                    DragonHornShape(mirrored: false)
                        .fill(character.hornColor.swiftUIColor)
                    DragonHornShape(mirrored: true)
                        .fill(character.hornColor.swiftUIColor)

                    // Head
                    DragonHeadShape()
                        .fill(character.bodyColor.swiftUIColor)
                        .overlay(
                            DragonHeadShape()
                                .stroke(PastelPalette.inkText.swiftUIColor.opacity(0.18), lineWidth: 2)
                        )

                    // Soft scale tufts on forehead
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

                    // Cute front paws
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
                .scaleEffect(reduceMotion ? 1.0 : (breathing ? 1.02 : 0.99))
                .offset(y: reduceMotion ? 0 : (breathing ? -4 : 2))
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 2.2).repeatForever(autoreverses: true),
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
                if !reduceMotion {
                    breathing = true
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(character.name)
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

// MARK: - Original Vector Shapes

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
        var path = Path()
        let bodyRect = CGRect(
            x: rect.width * 0.28,
            y: rect.height * 0.43,
            width: rect.width * 0.44,
            height: rect.height * 0.40
        )
        path.addRoundedRect(in: bodyRect, cornerSize: CGSize(width: rect.width * 0.22, height: rect.height * 0.22))
        return path
    }
}

struct DragonBellyShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let bellyRect = CGRect(
            x: rect.width * 0.36,
            y: rect.height * 0.51,
            width: rect.width * 0.28,
            height: rect.height * 0.28
        )
        path.addEllipse(in: bellyRect)
        return path
    }
}

struct DragonHeadShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let headRect = CGRect(
            x: rect.width * 0.29,
            y: rect.height * 0.21,
            width: rect.width * 0.42,
            height: rect.height * 0.33
        )
        path.addRoundedRect(in: headRect, cornerSize: CGSize(width: rect.width * 0.19, height: rect.height * 0.17))
        return path
    }
}

struct DragonHornShape: Shape {
    let mirrored: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let baseX = mirrored ? w * 0.62 : w * 0.38
        let tipX = mirrored ? w * 0.69 : w * 0.31
        let innerX = mirrored ? w * 0.56 : w * 0.44
        path.move(to: CGPoint(x: baseX, y: h * 0.25))
        path.addQuadCurve(
            to: CGPoint(x: tipX, y: h * 0.10),
            control: CGPoint(x: mirrored ? w * 0.72 : w * 0.28, y: h * 0.17)
        )
        path.addQuadCurve(
            to: CGPoint(x: innerX, y: h * 0.24),
            control: CGPoint(x: mirrored ? w * 0.61 : w * 0.39, y: h * 0.18)
        )
        path.closeSubpath()
        return path
    }
}

struct DragonWingShape: Shape {
    let mirrored: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let anchorX = mirrored ? w * 0.69 : w * 0.31
        let outerX = mirrored ? w * 0.90 : w * 0.10
        let midX = mirrored ? w * 0.85 : w * 0.15
        path.move(to: CGPoint(x: anchorX, y: h * 0.49))
        path.addQuadCurve(
            to: CGPoint(x: outerX, y: h * 0.33),
            control: CGPoint(x: mirrored ? w * 0.83 : w * 0.17, y: h * 0.34)
        )
        path.addQuadCurve(
            to: CGPoint(x: midX, y: h * 0.56),
            control: CGPoint(x: mirrored ? w * 0.92 : w * 0.08, y: h * 0.48)
        )
        path.addQuadCurve(
            to: CGPoint(x: anchorX, y: h * 0.63),
            control: CGPoint(x: mirrored ? w * 0.76 : w * 0.24, y: h * 0.63)
        )
        path.closeSubpath()
        return path
    }
}

struct DragonTailShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.64, y: h * 0.72))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.88, y: h * 0.64),
            control: CGPoint(x: w * 0.82, y: h * 0.79)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.79, y: h * 0.57),
            control: CGPoint(x: w * 0.90, y: h * 0.56)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.65, y: h * 0.66),
            control: CGPoint(x: w * 0.74, y: h * 0.68)
        )
        path.closeSubpath()
        return path
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
