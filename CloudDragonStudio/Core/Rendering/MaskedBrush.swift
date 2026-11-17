import CoreGraphics
import UIKit

enum PaintToolKind: String, CaseIterable, Codable, Identifiable, Sendable {
    case solid
    case rainbow
    case dots
    case stripes
    case stampStar
    case stampHeart
    case stampMoon
    case stampCloud

    var id: String { rawValue }

    var isStamp: Bool {
        switch self {
        case .stampStar, .stampHeart, .stampMoon, .stampCloud:
            return true
        case .solid, .rainbow, .dots, .stripes:
            return false
        }
    }

    var localizationKey: String {
        switch self {
        case .solid: return "scale.tool.solid"
        case .rainbow: return "scale.tool.rainbow"
        case .dots: return "scale.tool.dots"
        case .stripes: return "scale.tool.stripes"
        case .stampStar: return "scale.tool.star"
        case .stampHeart: return "scale.tool.heart"
        case .stampMoon: return "scale.tool.moon"
        case .stampCloud: return "scale.tool.cloud"
        }
    }
}

struct PaintStroke: Codable, Equatable, Sendable {
    var zone: DragonZone
    var tool: PaintToolKind
    var color: CodableColor
    var brushWidthNormalized: CGFloat
    var normalizedPoints: [CodablePoint]
}

struct CodablePoint: Codable, Equatable, Sendable {
    var x: CGFloat
    var y: CGFloat

    var cgPoint: CGPoint { CGPoint(x: x, y: y) }

    init(_ point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }

    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
}

struct PaintHistoryState: Equatable, Sendable {
    private(set) var snapshots: [[PaintStroke]] = [[]]
    private(set) var index: Int = 0

    var currentStrokes: [PaintStroke] {
        snapshots[index]
    }

    var canUndo: Bool {
        index > 0
    }

    var canRedo: Bool {
        index < snapshots.count - 1
    }

    mutating func commit(_ stroke: PaintStroke) {
        guard !stroke.normalizedPoints.isEmpty else { return }
        if index < snapshots.count - 1 {
            snapshots.removeSubrange((index + 1)...)
        }
        var next = currentStrokes
        next.append(stroke)
        snapshots.append(next)
        index = snapshots.count - 1
    }

    mutating func clear() {
        guard !currentStrokes.isEmpty else { return }
        if index < snapshots.count - 1 {
            snapshots.removeSubrange((index + 1)...)
        }
        snapshots.append([])
        index = snapshots.count - 1
    }

    mutating func undo() {
        guard canUndo else { return }
        index -= 1
    }

    mutating func redo() {
        guard canRedo else { return }
        index += 1
    }

    mutating func load(strokes: [PaintStroke]) {
        snapshots = [strokes]
        index = 0
    }
}

enum MaskedBrushRenderer {
    static let canvasPixelSize: CGFloat = 640

    static func renderZoneImages(
        strokes: [PaintStroke],
        size: CGFloat = canvasPixelSize
    ) -> [DragonZone: CGImage] {
        var result: [DragonZone: CGImage] = [:]
        for zone in DragonZone.allCases {
            let zoneStrokes = strokes.filter { $0.zone == zone }
            if !zoneStrokes.isEmpty, let img = renderImage(strokes: zoneStrokes, onlyZone: zone, size: size) {
                result[zone] = img
            }
        }
        return result
    }

    static func renderImage(
        strokes: [PaintStroke],
        onlyZone: DragonZone? = nil,
        size: CGFloat = canvasPixelSize
    ) -> CGImage? {
        let width = Int(size)
        let height = Int(size)
        guard width > 0, height > 0 else { return nil }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        // Flip CGContext so y=0 is top-left matching SwiftUI Canvas & DragGesture coordinates
        ctx.translateBy(x: 0, y: size)
        ctx.scaleBy(x: 1, y: -1)

        let canvasRect = CGRect(x: 0, y: 0, width: size, height: size)

        for stroke in strokes {
            if let onlyZone, stroke.zone != onlyZone { continue }
            guard !stroke.normalizedPoints.isEmpty else { continue }
            ctx.saveGState()
            let clipPath = DragonGeometry.combinedClipPath(for: stroke.zone, in: canvasRect)
            ctx.addPath(clipPath)
            ctx.clip()

            drawStroke(stroke, in: ctx, canvasSize: size)
            ctx.restoreGState()
        }

        return ctx.makeImage()
    }

    private static func drawStroke(_ stroke: PaintStroke, in ctx: CGContext, canvasSize: CGFloat) {
        let points = stroke.normalizedPoints.map {
            CGPoint(x: $0.x * canvasSize, y: $0.y * canvasSize)
        }
        let lineWidth = max(6, stroke.brushWidthNormalized * canvasSize)

        switch stroke.tool {
        case .solid:
            ctx.setStrokeColor(stroke.color.uiColor.cgColor)
            ctx.setFillColor(stroke.color.uiColor.cgColor)
            ctx.setLineWidth(lineWidth)
            ctx.setLineCap(.round)
            ctx.setLineJoin(.round)
            if points.count == 1 {
                let p = points[0]
                ctx.fillEllipse(in: CGRect(x: p.x - lineWidth * 0.5, y: p.y - lineWidth * 0.5, width: lineWidth, height: lineWidth))
            } else {
                ctx.beginPath()
                ctx.move(to: points[0])
                for p in points.dropFirst() {
                    ctx.addLine(to: p)
                }
                ctx.strokePath()
            }

        case .rainbow:
            ctx.setLineWidth(lineWidth)
            ctx.setLineCap(.round)
            ctx.setLineJoin(.round)
            if points.count == 1 {
                let p = points[0]
                ctx.setFillColor(UIColor(hue: 0.55, saturation: 0.65, brightness: 0.96, alpha: 1.0).cgColor)
                ctx.fillEllipse(in: CGRect(x: p.x - lineWidth * 0.5, y: p.y - lineWidth * 0.5, width: lineWidth, height: lineWidth))
            } else {
                for i in 1..<points.count {
                    let hue = CGFloat(i % 24) / 24.0
                    let segColor = UIColor(hue: hue, saturation: 0.62, brightness: 0.97, alpha: 1.0)
                    ctx.setStrokeColor(segColor.cgColor)
                    ctx.beginPath()
                    ctx.move(to: points[i - 1])
                    ctx.addLine(to: points[i])
                    ctx.strokePath()
                }
            }

        case .dots:
            ctx.setFillColor(stroke.color.uiColor.cgColor)
            let dotR = max(4, lineWidth * 0.28)
            var lastPlaced = CGPoint(x: -999, y: -999)
            let minSpacing = max(12, lineWidth * 0.72)
            for (idx, p) in points.enumerated() {
                if hypot(p.x - lastPlaced.x, p.y - lastPlaced.y) >= minSpacing {
                    lastPlaced = p
                    let offsetAngle = CGFloat(idx % 6) * (.pi / 3.0)
                    let dx = cos(offsetAngle) * lineWidth * 0.26
                    let dy = sin(offsetAngle) * lineWidth * 0.26
                    ctx.fillEllipse(in: CGRect(x: p.x - dotR, y: p.y - dotR, width: dotR * 2, height: dotR * 2))
                    ctx.fillEllipse(in: CGRect(x: p.x + dx - dotR * 0.6, y: p.y + dy - dotR * 0.6, width: dotR * 1.2, height: dotR * 1.2))
                }
            }

        case .stripes:
            ctx.setStrokeColor(stroke.color.uiColor.cgColor)
            ctx.setLineWidth(max(3, lineWidth * 0.22))
            ctx.setLineCap(.round)
            var lastPlaced = CGPoint(x: -999, y: -999)
            let spacing = max(10, lineWidth * 0.45)
            for p in points {
                if hypot(p.x - lastPlaced.x, p.y - lastPlaced.y) >= spacing {
                    lastPlaced = p
                    let half = lineWidth * 0.55
                    ctx.beginPath()
                    ctx.move(to: CGPoint(x: p.x - half * 0.7, y: p.y - half * 0.7))
                    ctx.addLine(to: CGPoint(x: p.x + half * 0.7, y: p.y + half * 0.7))
                    ctx.strokePath()
                }
            }

        case .stampStar, .stampHeart, .stampMoon, .stampCloud:
            ctx.setFillColor(stroke.color.uiColor.cgColor)
            let stampSize = max(20, lineWidth * 1.45)
            var lastPlaced = CGPoint(x: -999, y: -999)
            let spacing = stampSize * 1.15
            for p in points {
                if hypot(p.x - lastPlaced.x, p.y - lastPlaced.y) >= spacing {
                    lastPlaced = p
                    let stampRect = CGRect(
                        x: p.x - stampSize * 0.5,
                        y: p.y - stampSize * 0.5,
                        width: stampSize,
                        height: stampSize
                    )
                    ctx.addPath(stampPath(for: stroke.tool, in: stampRect))
                    ctx.fillPath()
                }
            }
        }
    }

    private static func stampPath(for tool: PaintToolKind, in rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        switch tool {
        case .stampStar:
            let cx = rect.midX
            let cy = rect.midY
            let outer = min(rect.width, rect.height) * 0.5
            let inner = outer * 0.42
            for i in 0..<10 {
                let angle = CGFloat(i) * (.pi / 5.0) - (.pi / 2.0)
                let r = (i % 2 == 0) ? outer : inner
                let pt = CGPoint(x: cx + cos(angle) * r, y: cy + sin(angle) * r)
                if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
            }
            path.closeSubpath()
        case .stampHeart:
            let w = rect.width
            let h = rect.height
            let x = rect.minX
            let y = rect.minY
            path.move(to: CGPoint(x: x + w * 0.5, y: y + h * 0.88))
            path.addCurve(
                to: CGPoint(x: x + w * 0.1, y: y + h * 0.34),
                control1: CGPoint(x: x + w * 0.2, y: y + h * 0.68),
                control2: CGPoint(x: x + w * 0.06, y: y + h * 0.48)
            )
            path.addCurve(
                to: CGPoint(x: x + w * 0.5, y: y + h * 0.28),
                control1: CGPoint(x: x + w * 0.14, y: y + h * 0.12),
                control2: CGPoint(x: x + w * 0.44, y: y + h * 0.12)
            )
            path.addCurve(
                to: CGPoint(x: x + w * 0.9, y: y + h * 0.34),
                control1: CGPoint(x: x + w * 0.56, y: y + h * 0.12),
                control2: CGPoint(x: x + w * 0.86, y: y + h * 0.12)
            )
            path.addCurve(
                to: CGPoint(x: x + w * 0.5, y: y + h * 0.88),
                control1: CGPoint(x: x + w * 0.94, y: y + h * 0.48),
                control2: CGPoint(x: x + w * 0.8, y: y + h * 0.68)
            )
            path.closeSubpath()
        case .stampMoon:
            let w = rect.width
            let h = rect.height
            let x = rect.minX
            let y = rect.minY
            path.move(to: CGPoint(x: x + w * 0.68, y: y + h * 0.14))
            path.addQuadCurve(
                to: CGPoint(x: x + w * 0.68, y: y + h * 0.86),
                control: CGPoint(x: x + w * 0.05, y: y + h * 0.50)
            )
            path.addQuadCurve(
                to: CGPoint(x: x + w * 0.68, y: y + h * 0.14),
                control: CGPoint(x: x + w * 0.42, y: y + h * 0.50)
            )
            path.closeSubpath()
        case .stampCloud:
            path.addEllipse(in: CGRect(x: rect.minX + rect.width * 0.05, y: rect.minY + rect.height * 0.38, width: rect.width * 0.42, height: rect.height * 0.48))
            path.addEllipse(in: CGRect(x: rect.minX + rect.width * 0.25, y: rect.minY + rect.height * 0.16, width: rect.width * 0.50, height: rect.height * 0.68))
            path.addEllipse(in: CGRect(x: rect.minX + rect.width * 0.53, y: rect.minY + rect.height * 0.36, width: rect.width * 0.42, height: rect.height * 0.50))
        default:
            path.addEllipse(in: rect)
        }
        return path
    }
}
