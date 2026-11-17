import CoreGraphics
import UIKit

enum PaintToolKind: String, CaseIterable, Codable, Identifiable, Sendable {
    case solid
    case gradient
    case rainbow
    case dots
    case stampStar
    case stampCloud
    case stampHeart
    case eraser

    var id: String { rawValue }

    var localizationKey: String {
        switch self {
        case .solid: return "scale.tool.solid"
        case .gradient: return "scale.tool.gradient"
        case .rainbow: return "scale.tool.rainbow"
        case .dots: return "scale.tool.dots"
        case .stampStar: return "scale.tool.star"
        case .stampCloud: return "scale.tool.cloud"
        case .stampHeart: return "scale.tool.heart"
        case .eraser: return "scale.tool.eraser"
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

enum MaskedBrushRenderer {
    static let canvasPixelSize: CGFloat = 640

    static func renderZoneImages(
        for character: CloudDragonCharacter,
        size: CGFloat = canvasPixelSize
    ) -> [DragonZone: CGImage] {
        var result: [DragonZone: CGImage] = [:]
        for zone in DragonZone.allCases {
            let strokes = character.strokes(for: zone)
            if !strokes.isEmpty, let img = renderImage(strokes: strokes, onlyZone: zone, size: size) {
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

        // Flip to match SwiftUI top-left coordinate system
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

        case .eraser:
            ctx.setBlendMode(.clear)
            ctx.setStrokeColor(UIColor.clear.cgColor)
            ctx.setFillColor(UIColor.clear.cgColor)
            ctx.setLineWidth(lineWidth * 1.25)
            ctx.setLineCap(.round)
            ctx.setLineJoin(.round)
            if points.count == 1 {
                let p = points[0]
                ctx.fillEllipse(in: CGRect(x: p.x - lineWidth * 0.62, y: p.y - lineWidth * 0.62, width: lineWidth * 1.25, height: lineWidth * 1.25))
            } else {
                ctx.beginPath()
                ctx.move(to: points[0])
                for p in points.dropFirst() {
                    ctx.addLine(to: p)
                }
                ctx.strokePath()
            }
            ctx.setBlendMode(.normal)

        case .gradient:
            guard let p1 = points.first, let p2 = points.last else { return }
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                stroke.color.withAlpha(0.90).uiColor.cgColor,
                UIColor.white.withAlphaComponent(0.25).cgColor
            ] as CFArray
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1]) {
                ctx.beginPath()
                ctx.move(to: p1)
                for p in points.dropFirst() {
                    ctx.addLine(to: p)
                }
                ctx.setLineWidth(lineWidth * 1.35)
                ctx.setLineCap(.round)
                ctx.setLineJoin(.round)
                ctx.replacePathWithStrokedPath()
                ctx.clip()
                ctx.drawLinearGradient(gradient, start: p1, end: p2, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
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
            let dotR = max(4, lineWidth * 0.30)
            var lastPlaced = CGPoint(x: -999, y: -999)
            let minSpacing = max(12, lineWidth * 0.72)
            for (idx, p) in points.enumerated() {
                if hypot(p.x - lastPlaced.x, p.y - lastPlaced.y) >= minSpacing {
                    lastPlaced = p
                    let offsetAngle = CGFloat(idx % 6) * (.pi / 3.0)
                    let dx = cos(offsetAngle) * lineWidth * 0.25
                    let dy = sin(offsetAngle) * lineWidth * 0.25
                    ctx.fillEllipse(in: CGRect(x: p.x - dotR, y: p.y - dotR, width: dotR * 2, height: dotR * 2))
                    ctx.fillEllipse(in: CGRect(x: p.x + dx - dotR * 0.6, y: p.y + dy - dotR * 0.6, width: dotR * 1.2, height: dotR * 1.2))
                }
            }

        case .stampStar, .stampCloud, .stampHeart:
            ctx.setFillColor(stroke.color.uiColor.cgColor)
            let stampRadius = max(12, lineWidth * 0.95)
            var lastPlaced = CGPoint(x: -999, y: -999)
            let spacing = stampRadius * 2.1
            for p in points {
                if hypot(p.x - lastPlaced.x, p.y - lastPlaced.y) >= spacing {
                    lastPlaced = p
                    switch stroke.tool {
                    case .stampStar:
                        ctx.addPath(DragonGeometry.starPath(center: p, outerRadius: stampRadius, innerRadius: stampRadius * 0.45))
                        ctx.fillPath()
                    case .stampHeart:
                        ctx.addPath(DragonGeometry.heartPath(center: p, radius: stampRadius))
                        ctx.fillPath()
                    case .stampCloud:
                        ctx.fillEllipse(in: CGRect(x: p.x - stampRadius * 0.85, y: p.y - stampRadius * 0.45, width: stampRadius * 0.9, height: stampRadius * 0.9))
                        ctx.fillEllipse(in: CGRect(x: p.x - stampRadius * 0.05, y: p.y - stampRadius * 0.45, width: stampRadius * 0.9, height: stampRadius * 0.9))
                        ctx.fillEllipse(in: CGRect(x: p.x - stampRadius * 0.55, y: p.y - stampRadius * 0.80, width: stampRadius * 1.1, height: stampRadius * 1.1))
                    default:
                        break
                    }
                }
            }
        }
    }
}
