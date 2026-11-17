import CoreGraphics
import SwiftUI

enum DragonGeometry {
    static func bodyPath(in rect: CGRect) -> CGPath {
        let bodyRect = CGRect(
            x: rect.minX + rect.width * 0.28,
            y: rect.minY + rect.height * 0.43,
            width: rect.width * 0.44,
            height: rect.height * 0.40
        )
        let corner = rect.width * 0.22
        return CGPath(
            roundedRect: bodyRect,
            cornerWidth: min(corner, bodyRect.width * 0.5),
            cornerHeight: min(corner, bodyRect.height * 0.5),
            transform: nil
        )
    }

    static func bellyPath(in rect: CGRect) -> CGPath {
        let bellyRect = CGRect(
            x: rect.minX + rect.width * 0.36,
            y: rect.minY + rect.height * 0.51,
            width: rect.width * 0.28,
            height: rect.height * 0.28
        )
        return CGPath(ellipseIn: bellyRect, transform: nil)
    }

    static func headPath(in rect: CGRect) -> CGPath {
        let headRect = CGRect(
            x: rect.minX + rect.width * 0.29,
            y: rect.minY + rect.height * 0.21,
            width: rect.width * 0.42,
            height: rect.height * 0.33
        )
        let corner = rect.width * 0.16
        return CGPath(
            roundedRect: headRect,
            cornerWidth: min(corner, headRect.width * 0.5),
            cornerHeight: min(corner, headRect.height * 0.5),
            transform: nil
        )
    }

    static func hornPath(in rect: CGRect, mirrored: Bool) -> CGPath {
        let path = CGMutablePath()
        let w = rect.width
        let h = rect.height
        let ox = rect.minX
        let oy = rect.minY
        let baseX = ox + (mirrored ? w * 0.62 : w * 0.38)
        let tipX = ox + (mirrored ? w * 0.69 : w * 0.31)
        let innerX = ox + (mirrored ? w * 0.56 : w * 0.44)
        path.move(to: CGPoint(x: baseX, y: oy + h * 0.25))
        path.addQuadCurve(
            to: CGPoint(x: tipX, y: oy + h * 0.10),
            control: CGPoint(x: ox + (mirrored ? w * 0.72 : w * 0.28), y: oy + h * 0.17)
        )
        path.addQuadCurve(
            to: CGPoint(x: innerX, y: oy + h * 0.24),
            control: CGPoint(x: ox + (mirrored ? w * 0.61 : w * 0.39), y: oy + h * 0.18)
        )
        path.closeSubpath()
        return path
    }

    static func wingPath(in rect: CGRect, mirrored: Bool) -> CGPath {
        let path = CGMutablePath()
        let w = rect.width
        let h = rect.height
        let ox = rect.minX
        let oy = rect.minY
        let anchorX = ox + (mirrored ? w * 0.69 : w * 0.31)
        let outerX = ox + (mirrored ? w * 0.90 : w * 0.10)
        let midX = ox + (mirrored ? w * 0.85 : w * 0.15)
        path.move(to: CGPoint(x: anchorX, y: oy + h * 0.49))
        path.addQuadCurve(
            to: CGPoint(x: outerX, y: oy + h * 0.33),
            control: CGPoint(x: ox + (mirrored ? w * 0.83 : w * 0.17), y: oy + h * 0.34)
        )
        path.addQuadCurve(
            to: CGPoint(x: midX, y: oy + h * 0.56),
            control: CGPoint(x: ox + (mirrored ? w * 0.92 : w * 0.08), y: oy + h * 0.48)
        )
        path.addQuadCurve(
            to: CGPoint(x: anchorX, y: oy + h * 0.63),
            control: CGPoint(x: ox + (mirrored ? w * 0.76 : w * 0.24), y: oy + h * 0.63)
        )
        path.closeSubpath()
        return path
    }

    static func tailPath(in rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        let w = rect.width
        let h = rect.height
        let ox = rect.minX
        let oy = rect.minY
        path.move(to: CGPoint(x: ox + w * 0.64, y: oy + h * 0.72))
        path.addQuadCurve(
            to: CGPoint(x: ox + w * 0.88, y: oy + h * 0.64),
            control: CGPoint(x: ox + w * 0.82, y: oy + h * 0.79)
        )
        path.addQuadCurve(
            to: CGPoint(x: ox + w * 0.79, y: oy + h * 0.57),
            control: CGPoint(x: ox + w * 0.90, y: oy + h * 0.56)
        )
        path.addQuadCurve(
            to: CGPoint(x: ox + w * 0.65, y: oy + h * 0.66),
            control: CGPoint(x: ox + w * 0.74, y: oy + h * 0.68)
        )
        path.closeSubpath()
        return path
    }

    static func clipPaths(for zone: DragonZone, in rect: CGRect) -> [CGPath] {
        switch zone {
        case .scales:
            return [bodyPath(in: rect), headPath(in: rect)]
        case .horns:
            return [hornPath(in: rect, mirrored: false), hornPath(in: rect, mirrored: true)]
        case .wings:
            return [wingPath(in: rect, mirrored: false), wingPath(in: rect, mirrored: true)]
        case .tail:
            return [tailPath(in: rect)]
        }
    }

    static func combinedClipPath(for zone: DragonZone, in rect: CGRect) -> CGPath {
        let combined = CGMutablePath()
        for sub in clipPaths(for: zone, in: rect) {
            combined.addPath(sub)
        }
        return combined
    }
}
