import CoreGraphics
import SwiftUI

/// Exact Chibi Cloud Dragon paths matching the ADR DragonPaths geometry
enum DragonGeometry {
    static func wingsPath(in rect: CGRect) -> CGPath {
        let w = rect.width
        let h = rect.height
        let ox = rect.minX
        let oy = rect.minY
        let path = CGMutablePath()

        // Left Wing
        path.move(to: CGPoint(x: ox + w * 0.28, y: oy + h * 0.44))
        path.addCurve(
            to: CGPoint(x: ox + w * 0.16, y: oy + h * 0.18),
            control1: CGPoint(x: ox + w * 0.10, y: oy + h * 0.36),
            control2: CGPoint(x: ox + w * 0.05, y: oy + h * 0.20)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.28, y: oy + h * 0.35),
            control1: CGPoint(x: ox + w * 0.25, y: oy + h * 0.18),
            control2: CGPoint(x: ox + w * 0.20, y: oy + h * 0.30)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.30, y: oy + h * 0.50),
            control1: CGPoint(x: ox + w * 0.18, y: oy + h * 0.40),
            control2: CGPoint(x: ox + w * 0.22, y: oy + h * 0.48)
        )
        path.closeSubpath()

        // Right Wing
        path.move(to: CGPoint(x: ox + w * 0.72, y: oy + h * 0.44))
        path.addCurve(
            to: CGPoint(x: ox + w * 0.84, y: oy + h * 0.18),
            control1: CGPoint(x: ox + w * 0.90, y: oy + h * 0.36),
            control2: CGPoint(x: ox + w * 0.95, y: oy + h * 0.20)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.72, y: oy + h * 0.35),
            control1: CGPoint(x: ox + w * 0.75, y: oy + h * 0.18),
            control2: CGPoint(x: ox + w * 0.80, y: oy + h * 0.30)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.70, y: oy + h * 0.50),
            control1: CGPoint(x: ox + w * 0.82, y: oy + h * 0.40),
            control2: CGPoint(x: ox + w * 0.78, y: oy + h * 0.48)
        )
        path.closeSubpath()

        return path
    }

    static func tailPath(in rect: CGRect) -> CGPath {
        let w = rect.width
        let h = rect.height
        let ox = rect.minX
        let oy = rect.minY
        let path = CGMutablePath()

        path.move(to: CGPoint(x: ox + w * 0.65, y: oy + h * 0.72))
        path.addCurve(
            to: CGPoint(x: ox + w * 0.92, y: oy + h * 0.60),
            control1: CGPoint(x: ox + w * 0.78, y: oy + h * 0.72),
            control2: CGPoint(x: ox + w * 0.88, y: oy + h * 0.68)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.85, y: oy + h * 0.80),
            control1: CGPoint(x: ox + w * 0.96, y: oy + h * 0.62),
            control2: CGPoint(x: ox + w * 0.94, y: oy + h * 0.75)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.60, y: oy + h * 0.78),
            control1: CGPoint(x: ox + w * 0.75, y: oy + h * 0.84),
            control2: CGPoint(x: ox + w * 0.66, y: oy + h * 0.80)
        )
        path.closeSubpath()

        // Twin fluffy cloud puffs at tail tip
        let r1 = w * 0.065
        path.addEllipse(in: CGRect(x: ox + w * 0.91 - r1, y: oy + h * 0.60 - r1, width: r1 * 2, height: r1 * 2))
        let r2 = w * 0.05
        path.addEllipse(in: CGRect(x: ox + w * 0.88 - r2, y: oy + h * 0.56 - r2, width: r2 * 2, height: r2 * 2))

        return path
    }

    static func hornsPath(in rect: CGRect) -> CGPath {
        let w = rect.width
        let h = rect.height
        let ox = rect.minX
        let oy = rect.minY
        let path = CGMutablePath()

        // Left Horn
        path.move(to: CGPoint(x: ox + w * 0.36, y: oy + h * 0.22))
        path.addCurve(
            to: CGPoint(x: ox + w * 0.24, y: oy + h * 0.06),
            control1: CGPoint(x: ox + w * 0.34, y: oy + h * 0.14),
            control2: CGPoint(x: ox + w * 0.26, y: oy + h * 0.08)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.42, y: oy + h * 0.20),
            control1: CGPoint(x: ox + w * 0.28, y: oy + h * 0.12),
            control2: CGPoint(x: ox + w * 0.38, y: oy + h * 0.16)
        )
        path.closeSubpath()

        // Right Horn
        path.move(to: CGPoint(x: ox + w * 0.64, y: oy + h * 0.22))
        path.addCurve(
            to: CGPoint(x: ox + w * 0.76, y: oy + h * 0.06),
            control1: CGPoint(x: ox + w * 0.66, y: oy + h * 0.14),
            control2: CGPoint(x: ox + w * 0.74, y: oy + h * 0.08)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.58, y: oy + h * 0.20),
            control1: CGPoint(x: ox + w * 0.72, y: oy + h * 0.12),
            control2: CGPoint(x: ox + w * 0.62, y: oy + h * 0.16)
        )
        path.closeSubpath()

        return path
    }

    static func bodyPath(in rect: CGRect) -> CGPath {
        let w = rect.width
        let h = rect.height
        let ox = rect.minX
        let oy = rect.minY
        let path = CGMutablePath()

        path.move(to: CGPoint(x: ox + w * 0.50, y: oy + h * 0.18))
        path.addCurve(
            to: CGPoint(x: ox + w * 0.72, y: oy + h * 0.36),
            control1: CGPoint(x: ox + w * 0.65, y: oy + h * 0.18),
            control2: CGPoint(x: ox + w * 0.72, y: oy + h * 0.26)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.72, y: oy + h * 0.60),
            control1: CGPoint(x: ox + w * 0.72, y: oy + h * 0.44),
            control2: CGPoint(x: ox + w * 0.66, y: oy + h * 0.50)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.65, y: oy + h * 0.82),
            control1: CGPoint(x: ox + w * 0.76, y: oy + h * 0.68),
            control2: CGPoint(x: ox + w * 0.74, y: oy + h * 0.80)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.50, y: oy + h * 0.80),
            control1: CGPoint(x: ox + w * 0.58, y: oy + h * 0.83),
            control2: CGPoint(x: ox + w * 0.55, y: oy + h * 0.79)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.35, y: oy + h * 0.82),
            control1: CGPoint(x: ox + w * 0.45, y: oy + h * 0.79),
            control2: CGPoint(x: ox + w * 0.42, y: oy + h * 0.83)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.28, y: oy + h * 0.60),
            control1: CGPoint(x: ox + w * 0.26, y: oy + h * 0.80),
            control2: CGPoint(x: ox + w * 0.24, y: oy + h * 0.68)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.28, y: oy + h * 0.36),
            control1: CGPoint(x: ox + w * 0.34, y: oy + h * 0.50),
            control2: CGPoint(x: ox + w * 0.28, y: oy + h * 0.44)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.50, y: oy + h * 0.18),
            control1: CGPoint(x: ox + w * 0.28, y: oy + h * 0.26),
            control2: CGPoint(x: ox + w * 0.35, y: oy + h * 0.18)
        )
        path.closeSubpath()

        return path
    }

    static func bellyPath(in rect: CGRect) -> CGPath {
        let w = rect.width
        let h = rect.height
        let ox = rect.minX
        let oy = rect.minY
        let path = CGMutablePath()

        path.move(to: CGPoint(x: ox + w * 0.50, y: oy + h * 0.48))
        path.addCurve(
            to: CGPoint(x: ox + w * 0.64, y: oy + h * 0.72),
            control1: CGPoint(x: ox + w * 0.62, y: oy + h * 0.48),
            control2: CGPoint(x: ox + w * 0.65, y: oy + h * 0.60)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.50, y: oy + h * 0.80),
            control1: CGPoint(x: ox + w * 0.63, y: oy + h * 0.79),
            control2: CGPoint(x: ox + w * 0.56, y: oy + h * 0.80)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.36, y: oy + h * 0.72),
            control1: CGPoint(x: ox + w * 0.44, y: oy + h * 0.80),
            control2: CGPoint(x: ox + w * 0.37, y: oy + h * 0.79)
        )
        path.addCurve(
            to: CGPoint(x: ox + w * 0.50, y: oy + h * 0.48),
            control1: CGPoint(x: ox + w * 0.35, y: oy + h * 0.60),
            control2: CGPoint(x: ox + w * 0.38, y: oy + h * 0.48)
        )
        path.closeSubpath()

        return path
    }

    static func combinedClipPath(for zone: DragonZone, in rect: CGRect) -> CGPath {
        switch zone {
        case .horns:
            return hornsPath(in: rect)
        case .wings:
            return wingsPath(in: rect)
        case .tail:
            return tailPath(in: rect)
        case .belly:
            return bellyPath(in: rect)
        case .body:
            return bodyPath(in: rect)
        }
    }

    static func starPath(center: CGPoint, outerRadius: CGFloat, innerRadius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        for i in 0..<5 {
            let outerAngle = -CGFloat.pi / 2.0 + CGFloat(i) * 2.0 * .pi / 5.0
            let innerAngle = outerAngle + .pi / 5.0
            let pOuter = CGPoint(x: center.x + outerRadius * cos(outerAngle), y: center.y + outerRadius * sin(outerAngle))
            let pInner = CGPoint(x: center.x + innerRadius * cos(innerAngle), y: center.y + innerRadius * sin(innerAngle))
            if i == 0 {
                path.move(to: pOuter)
            } else {
                path.addLine(to: pOuter)
            }
            path.addLine(to: pInner)
        }
        path.closeSubpath()
        return path
    }

    static func heartPath(center: CGPoint, radius: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: center.x, y: center.y + radius * 0.5))
        path.addCurve(
            to: CGPoint(x: center.x, y: center.y - radius * 0.4),
            control1: CGPoint(x: center.x - radius * 0.85, y: center.y - radius * 0.2),
            control2: CGPoint(x: center.x - radius * 0.85, y: center.y - radius * 0.85)
        )
        path.addCurve(
            to: CGPoint(x: center.x, y: center.y + radius * 0.5),
            control1: CGPoint(x: center.x + radius * 0.85, y: center.y - radius * 0.85),
            control2: CGPoint(x: center.x + radius * 0.85, y: center.y - radius * 0.2)
        )
        path.closeSubpath()
        return path
    }
}
