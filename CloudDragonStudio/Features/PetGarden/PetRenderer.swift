import CoreGraphics
import SwiftUI
import UIKit

enum CloudPetType: String, CaseIterable, Identifiable {
    case rabbit
    case fox
    case kitten

    var id: String { rawValue }
}

struct PetCanvasView: View {
    let petType: CloudPetType

    var body: some View {
        Canvas { graphicsContext, size in
            graphicsContext.withCGContext { ctx in
                drawPet(petType, in: ctx, size: size)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(petType.rawValue)
    }

    private func drawPet(_ pet: CloudPetType, in ctx: CGContext, size: CGSize) {
        let cx = size.width * 0.5
        let cy = size.height * 0.5
        let scale = min(size.width, size.height) / 135.0
        ctx.saveGState()
        ctx.translateBy(x: cx, y: cy)
        ctx.scaleBy(x: scale, y: scale)

        let stroke = PastelPalette.strokeSoft.withAlpha(0.32).uiColor.cgColor
        let pink = PastelPalette.roseSoft.uiColor.cgColor
        let dark = PastelPalette.textDark.uiColor.cgColor
        let white = UIColor.white.cgColor

        switch pet {
        case .rabbit:
            let body = UIColor(red: 0.973, green: 0.980, blue: 0.988, alpha: 1.0).cgColor
            for sign in [-1.0, 1.0] {
                let ear = CGRect(x: sign * 28 - 11, y: -45 - 30, width: 22, height: 60)
                ctx.setFillColor(body); ctx.fillEllipse(in: ear)
                ctx.setStrokeColor(stroke); ctx.setLineWidth(3.5); ctx.strokeEllipse(in: ear)
                let inner = CGRect(x: sign * 28 - 6, y: -43 - 21, width: 12, height: 42)
                ctx.setFillColor(pink); ctx.fillEllipse(in: inner)
            }
            let head = CGRect(x: -44, y: 8 - 44, width: 88, height: 88)
            ctx.setFillColor(body); ctx.fillEllipse(in: head)
            ctx.setStrokeColor(stroke); ctx.setLineWidth(3.5); ctx.strokeEllipse(in: head)

            ctx.setFillColor(pink)
            ctx.fillEllipse(in: CGRect(x: -26 - 7, y: 18 - 4.5, width: 14, height: 9))
            ctx.fillEllipse(in: CGRect(x: 26 - 7, y: 18 - 4.5, width: 14, height: 9))

            for ex in [-16.0, 16.0] {
                ctx.setFillColor(dark); ctx.fillEllipse(in: CGRect(x: ex - 7, y: 6 - 7, width: 14, height: 14))
                ctx.setFillColor(white); ctx.fillEllipse(in: CGRect(x: ex + 2 - 2.5, y: 4 - 2.5, width: 5, height: 5))
            }
            ctx.setFillColor(pink); ctx.fillEllipse(in: CGRect(x: -3.5, y: 14 - 2.5, width: 7, height: 5))
            drawPetSmile(in: ctx, cx: 0, cy: 20, width: 10, color: dark)

        case .fox:
            let orange = UIColor(red: 1.0, green: 0.624, blue: 0.263, alpha: 1.0).cgColor
            let cream = PastelPalette.cloudWhite.uiColor.cgColor
            for sign in [-1.0, 1.0] {
                let ear = CGMutablePath()
                ear.move(to: CGPoint(x: sign * 42, y: -8))
                ear.addLine(to: CGPoint(x: sign * 30, y: -50))
                ear.addLine(to: CGPoint(x: sign * 10, y: -20))
                ear.closeSubpath()
                ctx.addPath(ear); ctx.setFillColor(orange); ctx.fillPath()
                ctx.addPath(ear); ctx.setStrokeColor(stroke); ctx.setLineWidth(3.5); ctx.strokePath()
            }
            let head = CGRect(x: -44, y: 5 - 44, width: 88, height: 88)
            ctx.setFillColor(orange); ctx.fillEllipse(in: head)
            ctx.setStrokeColor(stroke); ctx.setLineWidth(3.5); ctx.strokeEllipse(in: head)

            let muzzle = CGMutablePath()
            muzzle.move(to: CGPoint(x: -32, y: 12))
            muzzle.addQuadCurve(to: CGPoint(x: 32, y: 12), control: CGPoint(x: 0, y: -4))
            muzzle.addQuadCurve(to: CGPoint(x: -32, y: 12), control: CGPoint(x: 0, y: 50))
            muzzle.closeSubpath()
            ctx.addPath(muzzle); ctx.setFillColor(cream); ctx.fillPath()

            ctx.setFillColor(pink)
            ctx.fillEllipse(in: CGRect(x: -24 - 6, y: 16 - 4, width: 12, height: 8))
            ctx.fillEllipse(in: CGRect(x: 24 - 6, y: 16 - 4, width: 12, height: 8))

            for ex in [-15.0, 15.0] {
                ctx.setFillColor(dark); ctx.fillEllipse(in: CGRect(x: ex - 6, y: 4 - 6, width: 12, height: 12))
                ctx.setFillColor(white); ctx.fillEllipse(in: CGRect(x: ex + 2 - 2.2, y: 2 - 2.2, width: 4.4, height: 4.4))
            }
            ctx.setFillColor(dark); ctx.fillEllipse(in: CGRect(x: -4.5, y: 18 - 4.5, width: 9, height: 9))

        case .kitten:
            let butter = PastelPalette.butterYellow.uiColor.cgColor
            for sign in [-1.0, 1.0] {
                let ear = CGMutablePath()
                ear.move(to: CGPoint(x: sign * 38, y: -5))
                ear.addLine(to: CGPoint(x: sign * 28, y: -45))
                ear.addLine(to: CGPoint(x: sign * 8, y: -22))
                ear.closeSubpath()
                ctx.addPath(ear); ctx.setFillColor(butter); ctx.fillPath()
                ctx.addPath(ear); ctx.setStrokeColor(stroke); ctx.setLineWidth(3.5); ctx.strokePath()
            }
            let head = CGRect(x: -44, y: 6 - 44, width: 88, height: 88)
            ctx.setFillColor(butter); ctx.fillEllipse(in: head)
            ctx.setStrokeColor(stroke); ctx.setLineWidth(3.5); ctx.strokeEllipse(in: head)

            ctx.setFillColor(pink)
            ctx.fillEllipse(in: CGRect(x: -25 - 7, y: 18 - 4.5, width: 14, height: 9))
            ctx.fillEllipse(in: CGRect(x: 25 - 7, y: 18 - 4.5, width: 14, height: 9))

            for ex in [-15.0, 15.0] {
                ctx.setFillColor(dark); ctx.fillEllipse(in: CGRect(x: ex - 7, y: 5 - 7, width: 14, height: 14))
                ctx.setFillColor(white); ctx.fillEllipse(in: CGRect(x: ex + 2 - 2.5, y: 3 - 2.5, width: 5, height: 5))
            }
            ctx.setFillColor(pink); ctx.fillEllipse(in: CGRect(x: -3, y: 15 - 2.2, width: 6, height: 4.5))
            ctx.setStrokeColor(dark); ctx.setLineWidth(2.0); ctx.setLineCap(.round)
            for sign in [-1.0, 1.0] {
                ctx.move(to: CGPoint(x: sign * 24, y: 12)); ctx.addLine(to: CGPoint(x: sign * 42, y: 10))
                ctx.move(to: CGPoint(x: sign * 24, y: 17)); ctx.addLine(to: CGPoint(x: sign * 42, y: 19))
            }
            ctx.strokePath()
            drawPetSmile(in: ctx, cx: 0, cy: 20, width: 8, color: dark)
        }

        ctx.restoreGState()
    }

    private func drawPetSmile(in ctx: CGContext, cx: CGFloat, cy: CGFloat, width: CGFloat, color: CGColor) {
        ctx.setStrokeColor(color)
        ctx.setLineWidth(2.5)
        ctx.setLineCap(.round)
        ctx.move(to: CGPoint(x: cx - width, y: cy))
        ctx.addQuadCurve(to: CGPoint(x: cx, y: cy), control: CGPoint(x: cx - width * 0.5, y: cy + 6))
        ctx.addQuadCurve(to: CGPoint(x: cx + width, y: cy), control: CGPoint(x: cx + width * 0.5, y: cy + 6))
        ctx.strokePath()
    }
}
