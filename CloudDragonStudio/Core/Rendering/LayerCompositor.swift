import CoreGraphics
import SwiftUI
import UIKit

enum CoreGraphicsDragonDrawer {
    static func drawDragon(
        in ctx: CGContext,
        rect: CGRect,
        character: CloudDragonCharacter,
        catalog: [CatalogItem] = CatalogLoader.fallbackCatalog,
        zonePaintImages: [DragonZone: CGImage] = [:],
        highlightedZone: DragonZone? = nil,
        wavePhase: CGFloat = 0.0
    ) {
        let w = rect.width
        let h = rect.height
        let outlineColor = PastelPalette.strokeSoft.withAlpha(0.42).uiColor.cgColor
        let layers = LayerCompositor.orderedLayers(for: character, highlightedZone: highlightedZone)

        for layer in layers {
            switch layer {
            case .backWingsDeco:
                if let wingsId = character.equippedItems[ItemCategory.wingsDeco.rawValue] {
                    let color = LayerCompositor.resolvedColor(for: wingsId, character: character, catalog: catalog).uiColor
                    drawBackWingsDeco(id: wingsId, color: color, in: ctx, rect: rect)
                }

            case .tail:
                let tailPath = DragonGeometry.tailPath(in: rect)
                ctx.saveGState()
                ctx.addPath(tailPath)
                ctx.setFillColor(character.bodyColor.uiColor.cgColor)
                ctx.fillPath()
                drawZonePaint(.tail, clipPath: tailPath, images: zonePaintImages, in: ctx, rect: rect)
                ctx.addPath(tailPath)
                ctx.setStrokeColor(outlineColor)
                ctx.setLineWidth(max(2.0, w * 0.010))
                ctx.setLineCap(.round)
                ctx.setLineJoin(.round)
                ctx.strokePath()
                ctx.restoreGState()

            case .wings:
                let wingsPath = DragonGeometry.wingsPath(in: rect)
                ctx.saveGState()
                ctx.addPath(wingsPath)
                ctx.setFillColor(character.wingColor.uiColor.cgColor)
                ctx.fillPath()
                drawZonePaint(.wings, clipPath: wingsPath, images: zonePaintImages, in: ctx, rect: rect)
                ctx.addPath(wingsPath)
                ctx.setStrokeColor(outlineColor)
                ctx.setLineWidth(max(2.0, w * 0.010))
                ctx.setLineCap(.round)
                ctx.setLineJoin(.round)
                ctx.strokePath()

                // Wing ribs
                ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.55).cgColor)
                ctx.setLineWidth(max(1.5, w * 0.007))
                ctx.move(to: CGPoint(x: rect.minX + w * 0.26, y: rect.minY + h * 0.36))
                ctx.addLine(to: CGPoint(x: rect.minX + w * 0.16, y: rect.minY + h * 0.24))
                ctx.move(to: CGPoint(x: rect.minX + w * 0.74, y: rect.minY + h * 0.36))
                ctx.addLine(to: CGPoint(x: rect.minX + w * 0.84, y: rect.minY + h * 0.24))
                ctx.strokePath()
                ctx.restoreGState()

            case .dorsalSpikes:
                ctx.saveGState()
                ctx.setFillColor(character.hornColor.withAlpha(0.92).uiColor.cgColor)
                let spikes: [(CGFloat, CGFloat)] = [(0.16, 0.035), (0.20, 0.038), (0.25, 0.035)]
                for (sy, sr) in spikes {
                    let r = w * sr
                    ctx.fillEllipse(in: CGRect(x: rect.minX + w * 0.50 - r, y: rect.minY + h * sy - r, width: r * 2, height: r * 2))
                }
                ctx.restoreGState()

            case .horns:
                let hornsPath = DragonGeometry.hornsPath(in: rect)
                ctx.saveGState()
                ctx.addPath(hornsPath)
                ctx.setFillColor(character.hornColor.uiColor.cgColor)
                ctx.fillPath()
                drawZonePaint(.horns, clipPath: hornsPath, images: zonePaintImages, in: ctx, rect: rect)
                ctx.addPath(hornsPath)
                ctx.setStrokeColor(outlineColor)
                ctx.setLineWidth(max(2.0, w * 0.010))
                ctx.strokePath()
                ctx.restoreGState()

            case .body:
                let bodyPath = DragonGeometry.bodyPath(in: rect)
                ctx.saveGState()
                ctx.addPath(bodyPath)
                ctx.setFillColor(character.bodyColor.uiColor.cgColor)
                ctx.fillPath()
                drawZonePaint(.body, clipPath: bodyPath, images: zonePaintImages, in: ctx, rect: rect)
                ctx.addPath(bodyPath)
                ctx.setStrokeColor(outlineColor)
                ctx.setLineWidth(max(2.0, w * 0.010))
                ctx.strokePath()
                ctx.restoreGState()

            case .belly:
                let bellyPath = DragonGeometry.bellyPath(in: rect)
                ctx.saveGState()
                ctx.addPath(bellyPath)
                ctx.setFillColor(character.bellyColor.uiColor.cgColor)
                ctx.fillPath()
                drawZonePaint(.belly, clipPath: bellyPath, images: zonePaintImages, in: ctx, rect: rect)

                // Belly scale arcs
                ctx.setStrokeColor(PastelPalette.butterDark.withAlpha(0.35).uiColor.cgColor)
                ctx.setLineWidth(max(1.5, w * 0.007))
                ctx.setLineCap(.round)
                for row in 0..<3 {
                    let y = rect.minY + h * (0.55 + CGFloat(row) * 0.07)
                    ctx.move(to: CGPoint(x: rect.minX + w * 0.44, y: y))
                    ctx.addQuadCurve(
                        to: CGPoint(x: rect.minX + w * 0.56, y: y),
                        control: CGPoint(x: rect.minX + w * 0.50, y: y + h * 0.03)
                    )
                    ctx.strokePath()
                }

                ctx.addPath(bellyPath)
                ctx.setStrokeColor(outlineColor)
                ctx.setLineWidth(max(2.0, w * 0.010))
                ctx.strokePath()
                ctx.restoreGState()

            case .robe:
                if let robeId = character.equippedItems[ItemCategory.robe.rawValue] {
                    let color = LayerCompositor.resolvedColor(for: robeId, character: character, catalog: catalog).uiColor
                    drawRobe(id: robeId, color: color, in: ctx, rect: rect)
                }

            case .paws:
                ctx.saveGState()
                let pawColor = character.bodyColor.uiColor.cgColor
                let pawStroke = PastelPalette.strokeSoft.withAlpha(0.35).uiColor.cgColor
                let pw = w * 0.08
                let ph = h * 0.06
                let leftRect = CGRect(x: rect.minX + w * 0.34 - pw * 0.5, y: rect.minY + h * 0.52 - ph * 0.5, width: pw, height: ph)
                ctx.setFillColor(pawColor)
                ctx.fillEllipse(in: leftRect)
                ctx.setStrokeColor(pawStroke)
                ctx.setLineWidth(max(1.5, w * 0.008))
                ctx.strokeEllipse(in: leftRect)

                let waveDx = character.pose == .waving ? sin(wavePhase * 4.0 * .pi) * w * 0.022 : 0
                let rightY = character.pose == .waving ? 0.46 : 0.52
                let rightRect = CGRect(x: rect.minX + w * 0.66 + waveDx - pw * 0.5, y: rect.minY + h * rightY - ph * 0.5, width: pw, height: ph)
                ctx.setFillColor(pawColor)
                ctx.fillEllipse(in: rightRect)
                ctx.setStrokeColor(pawStroke)
                ctx.strokeEllipse(in: rightRect)
                ctx.restoreGState()

            case .face:
                drawFace(character: character, in: ctx, rect: rect)

            case .glasses:
                if let glassesId = character.equippedItems[ItemCategory.glasses.rawValue] {
                    let color = LayerCompositor.resolvedColor(for: glassesId, character: character, catalog: catalog).uiColor
                    drawGlasses(id: glassesId, color: color, in: ctx, rect: rect)
                }

            case .scarf:
                if let scarfId = character.equippedItems[ItemCategory.scarf.rawValue] {
                    let color = LayerCompositor.resolvedColor(for: scarfId, character: character, catalog: catalog).uiColor
                    drawScarf(id: scarfId, color: color, in: ctx, rect: rect)
                }

            case .hat:
                if let hatId = character.equippedItems[ItemCategory.hat.rawValue] {
                    let color = LayerCompositor.resolvedColor(for: hatId, character: character, catalog: catalog).uiColor
                    drawHat(id: hatId, color: color, in: ctx, rect: rect)
                }

            case .floatingHalo:
                let haloColor = LayerCompositor.resolvedColor(for: "wings_halo", character: character, catalog: catalog).uiColor
                drawHalo(color: haloColor, in: ctx, rect: rect)

            case .selectionAura:
                if let zone = highlightedZone {
                    ctx.saveGState()
                    let maskPath = DragonGeometry.combinedClipPath(for: zone, in: rect)
                    ctx.addPath(maskPath)
                    ctx.setStrokeColor(PastelPalette.butterYellow.withAlpha(0.85).uiColor.cgColor)
                    ctx.setLineWidth(max(3.0, w * 0.015))
                    ctx.setLineCap(.round)
                    ctx.setLineJoin(.round)
                    ctx.strokePath()
                    ctx.restoreGState()
                }
            }
        }
    }

    private static func drawZonePaint(
        _ zone: DragonZone,
        clipPath: CGPath,
        images: [DragonZone: CGImage],
        in ctx: CGContext,
        rect: CGRect
    ) {
        guard let cgImg = images[zone] else { return }
        ctx.saveGState()
        ctx.addPath(clipPath)
        ctx.clip()
        // CGContext image drawing uses bottom-left origin relative to current flipped CTM: flip locally inside rect
        ctx.translateBy(x: rect.minX, y: rect.maxY)
        ctx.scaleBy(x: 1, y: -1)
        ctx.draw(cgImg, in: CGRect(x: 0, y: 0, width: rect.width, height: rect.height))
        ctx.restoreGState()
    }

    private static func drawFace(character: CloudDragonCharacter, in ctx: CGContext, rect: CGRect) {
        let w = rect.width
        let h = rect.height
        let eyeY = rect.minY + h * 0.33
        let leftX = rect.minX + w * 0.42
        let rightX = rect.minX + w * 0.58
        let eyeR = w * 0.045
        let darkColor = UIColor(red: 0.169, green: 0.227, blue: 0.259, alpha: 1.0).cgColor

        ctx.saveGState()

        // Left eye
        ctx.setFillColor(darkColor)
        ctx.fillEllipse(in: CGRect(x: leftX - eyeR, y: eyeY - eyeR, width: eyeR * 2, height: eyeR * 2))
        ctx.setFillColor(UIColor.white.cgColor)
        let hl1 = eyeR * 0.4
        ctx.fillEllipse(in: CGRect(x: leftX - eyeR * 0.35 - hl1, y: eyeY - eyeR * 0.35 - hl1, width: hl1 * 2, height: hl1 * 2))
        let hl2 = eyeR * 0.2
        ctx.fillEllipse(in: CGRect(x: leftX + eyeR * 0.35 - hl2, y: eyeY + eyeR * 0.35 - hl2, width: hl2 * 2, height: hl2 * 2))

        // Right eye
        if character.expression == .wink {
            ctx.setStrokeColor(darkColor)
            ctx.setLineWidth(max(2.5, w * 0.012))
            ctx.setLineCap(.round)
            ctx.move(to: CGPoint(x: rightX - w * 0.035, y: eyeY))
            ctx.addQuadCurve(to: CGPoint(x: rightX + w * 0.035, y: eyeY), control: CGPoint(x: rightX, y: eyeY + h * 0.025))
            ctx.strokePath()
        } else {
            ctx.setFillColor(darkColor)
            ctx.fillEllipse(in: CGRect(x: rightX - eyeR, y: eyeY - eyeR, width: eyeR * 2, height: eyeR * 2))
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fillEllipse(in: CGRect(x: rightX - eyeR * 0.35 - hl1, y: eyeY - eyeR * 0.35 - hl1, width: hl1 * 2, height: hl1 * 2))
            ctx.fillEllipse(in: CGRect(x: rightX + eyeR * 0.35 - hl2, y: eyeY + eyeR * 0.35 - hl2, width: hl2 * 2, height: hl2 * 2))
        }

        // Rosy blush cheeks
        ctx.setFillColor(PastelPalette.roseSoft.withAlpha(0.65).uiColor.cgColor)
        let bw = w * 0.09
        let bh = h * 0.04
        ctx.fillEllipse(in: CGRect(x: rect.minX + w * 0.35 - bw * 0.5, y: rect.minY + h * 0.37 - bh * 0.5, width: bw, height: bh))
        ctx.fillEllipse(in: CGRect(x: rect.minX + w * 0.65 - bw * 0.5, y: rect.minY + h * 0.37 - bh * 0.5, width: bw, height: bh))

        // Mouth
        if character.expression == .eating {
            let mr = w * 0.035
            ctx.setFillColor(UIColor(red: 0.91, green: 0.596, blue: 0.455, alpha: 1.0).cgColor)
            ctx.fillEllipse(in: CGRect(x: rect.minX + w * 0.50 - mr, y: rect.minY + h * 0.39 - mr, width: mr * 2, height: mr * 2))
        } else {
            ctx.setStrokeColor(darkColor)
            ctx.setLineWidth(max(2.0, w * 0.009))
            ctx.setLineCap(.round)
            ctx.move(to: CGPoint(x: rect.minX + w * 0.47, y: rect.minY + h * 0.38))
            ctx.addQuadCurve(
                to: CGPoint(x: rect.minX + w * 0.53, y: rect.minY + h * 0.38),
                control: CGPoint(x: rect.minX + w * 0.50, y: rect.minY + h * 0.415)
            )
            ctx.strokePath()
        }
        ctx.restoreGState()
    }

    // MARK: - Hats (Exact ADR Shapes)
    static func drawHat(id: String, color: UIColor, in ctx: CGContext, rect: CGRect) {
        let w = rect.width
        let h = rect.height
        let ox = rect.minX
        let oy = rect.minY
        ctx.saveGState()

        switch id {
        case "hat_star_crown":
            let path = CGMutablePath()
            path.move(to: CGPoint(x: ox + w * 0.38, y: oy + h * 0.17))
            path.addLine(to: CGPoint(x: ox + w * 0.36, y: oy + h * 0.09))
            path.addLine(to: CGPoint(x: ox + w * 0.44, y: oy + h * 0.13))
            path.addLine(to: CGPoint(x: ox + w * 0.50, y: oy + h * 0.05))
            path.addLine(to: CGPoint(x: ox + w * 0.56, y: oy + h * 0.13))
            path.addLine(to: CGPoint(x: ox + w * 0.64, y: oy + h * 0.09))
            path.addLine(to: CGPoint(x: ox + w * 0.62, y: oy + h * 0.17))
            path.closeSubpath()
            ctx.addPath(path)
            ctx.setFillColor(color.cgColor)
            ctx.fillPath()
            ctx.addPath(path)
            ctx.setStrokeColor(PastelPalette.butterDark.uiColor.cgColor)
            ctx.setLineWidth(max(2, w * 0.009))
            ctx.strokePath()

            ctx.setFillColor(PastelPalette.roseDark.uiColor.cgColor)
            ctx.addPath(DragonGeometry.heartPath(center: CGPoint(x: ox + w * 0.50, y: oy + h * 0.065), radius: w * 0.02))
            ctx.fillPath()

            ctx.setFillColor(PastelPalette.skyBlue.uiColor.cgColor)
            let jr = w * 0.015
            ctx.fillEllipse(in: CGRect(x: ox + w * 0.36 - jr, y: oy + h * 0.09 - jr, width: jr * 2, height: jr * 2))
            ctx.fillEllipse(in: CGRect(x: ox + w * 0.64 - jr, y: oy + h * 0.09 - jr, width: jr * 2, height: jr * 2))

            ctx.setFillColor(UIColor.white.cgColor)
            let pr = w * 0.011
            for i in 0..<4 {
                let px = ox + w * (0.42 + CGFloat(i) * 0.05)
                ctx.fillEllipse(in: CGRect(x: px - pr, y: oy + h * 0.16 - pr, width: pr * 2, height: pr * 2))
            }

        case "hat_cloud_beret":
            ctx.translateBy(x: ox + w * 0.52, y: oy + h * 0.14)
            ctx.rotate(by: 0.12)
            let puffs: [CGRect] = [
                CGRect(x: -w * 0.17, y: -h * 0.045, width: w * 0.22, height: h * 0.09),
                CGRect(x: -w * 0.05, y: -h * 0.055, width: w * 0.22, height: h * 0.09),
                CGRect(x: -w * 0.13, y: -h * 0.085, width: w * 0.26, height: h * 0.10),
                CGRect(x: -w * 0.16, y: -h * 0.025, width: w * 0.32, height: h * 0.08)
            ]
            ctx.setFillColor(color.cgColor)
            for p in puffs { ctx.fillEllipse(in: p) }
            ctx.setStrokeColor(PastelPalette.strokeSoft.withAlpha(0.4).uiColor.cgColor)
            ctx.setLineWidth(max(1.5, w * 0.008))
            for p in puffs { ctx.strokeEllipse(in: p) }

            ctx.setStrokeColor(PastelPalette.butterWarm.uiColor.cgColor)
            ctx.setLineWidth(max(2.5, w * 0.011))
            ctx.setLineCap(.round)
            ctx.move(to: CGPoint(x: 0, y: -h * 0.06))
            ctx.addLine(to: CGPoint(x: w * 0.01, y: -h * 0.095))
            ctx.strokePath()

            ctx.setFillColor(PastelPalette.butterYellow.uiColor.cgColor)
            ctx.addPath(DragonGeometry.starPath(center: CGPoint(x: w * 0.08, y: h * 0.005), outerRadius: w * 0.025, innerRadius: w * 0.011))
            ctx.fillPath()

        case "hat_flower_wreath":
            ctx.setStrokeColor(PastelPalette.mintGreen.uiColor.cgColor)
            ctx.setLineWidth(max(2.5, w * 0.013))
            ctx.setLineCap(.round)
            ctx.move(to: CGPoint(x: ox + w * 0.33, y: oy + h * 0.18))
            ctx.addQuadCurve(to: CGPoint(x: ox + w * 0.67, y: oy + h * 0.18), control: CGPoint(x: ox + w * 0.50, y: oy + h * 0.13))
            ctx.strokePath()

            let flowers: [(CGFloat, CGFloat, CGFloat, UIColor)] = [
                (0.35, 0.175, 0.024, PastelPalette.skyBlue.uiColor),
                (0.42, 0.150, 0.026, PastelPalette.butterYellow.uiColor),
                (0.50, 0.135, 0.032, color),
                (0.58, 0.150, 0.026, PastelPalette.lavenderPurple.uiColor),
                (0.65, 0.175, 0.024, PastelPalette.roseSoft.uiColor)
            ]
            for (fx, fy, fr, fc) in flowers {
                let cx = ox + w * fx
                let cy = oy + h * fy
                let rad = w * fr
                ctx.setFillColor(fc.cgColor)
                for i in 0..<5 {
                    let a = CGFloat(i) * 2 * .pi / 5
                    let px = cx + rad * 0.65 * cos(a)
                    let py = cy + rad * 0.65 * sin(a)
                    let pr = rad * 0.48
                    ctx.fillEllipse(in: CGRect(x: px - pr, y: py - pr, width: pr * 2, height: pr * 2))
                }
                let cr = rad * 0.32
                ctx.setFillColor(PastelPalette.butterWarm.uiColor.cgColor)
                ctx.fillEllipse(in: CGRect(x: cx - cr, y: cy - cr, width: cr * 2, height: cr * 2))
            }

        case "hat_nightcap":
            let cap = CGMutablePath()
            cap.move(to: CGPoint(x: ox + w * 0.38, y: oy + h * 0.16))
            cap.addCurve(to: CGPoint(x: ox + w * 0.64, y: oy + h * 0.10), control1: CGPoint(x: ox + w * 0.42, y: oy + h * 0.06), control2: CGPoint(x: ox + w * 0.56, y: oy + h * 0.04))
            cap.addCurve(to: CGPoint(x: ox + w * 0.71, y: oy + h * 0.26), control1: CGPoint(x: ox + w * 0.72, y: oy + h * 0.15), control2: CGPoint(x: ox + w * 0.74, y: oy + h * 0.23))
            cap.addCurve(to: CGPoint(x: ox + w * 0.58, y: oy + h * 0.14), control1: CGPoint(x: ox + w * 0.66, y: oy + h * 0.22), control2: CGPoint(x: ox + w * 0.64, y: oy + h * 0.15))
            cap.addCurve(to: CGPoint(x: ox + w * 0.40, y: oy + h * 0.18), control1: CGPoint(x: ox + w * 0.52, y: oy + h * 0.14), control2: CGPoint(x: ox + w * 0.46, y: oy + h * 0.16))
            cap.closeSubpath()
            ctx.addPath(cap)
            ctx.setFillColor(color.cgColor)
            ctx.fillPath()
            ctx.addPath(cap)
            ctx.setStrokeColor(PastelPalette.strokeSoft.withAlpha(0.4).uiColor.cgColor)
            ctx.setLineWidth(max(1.5, w * 0.008))
            ctx.strokePath()

            let pomR = w * 0.042
            let pomRect = CGRect(x: ox + w * 0.71 - pomR, y: oy + h * 0.26 - pomR, width: pomR * 2, height: pomR * 2)
            ctx.setFillColor(UIColor.white.cgColor)
            ctx.fillEllipse(in: pomRect)
            ctx.setStrokeColor(PastelPalette.strokeSoft.withAlpha(0.3).uiColor.cgColor)
            ctx.strokeEllipse(in: pomRect)

            ctx.setFillColor(UIColor.white.cgColor)
            let rimR = w * 0.022
            for i in 0..<6 {
                let rx = ox + w * (0.38 + CGFloat(i) * 0.045)
                ctx.fillEllipse(in: CGRect(x: rx - rimR, y: oy + h * 0.17 - rimR, width: rimR * 2, height: rimR * 2))
            }

        case "hat_dragon_tiara":
            ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.9).cgColor)
            ctx.setLineWidth(max(2.0, w * 0.011))
            ctx.setLineCap(.round)
            ctx.move(to: CGPoint(x: ox + w * 0.35, y: oy + h * 0.17))
            ctx.addCurve(to: CGPoint(x: ox + w * 0.50, y: oy + h * 0.07), control1: CGPoint(x: ox + w * 0.42, y: oy + h * 0.10), control2: CGPoint(x: ox + w * 0.46, y: oy + h * 0.08))
            ctx.addCurve(to: CGPoint(x: ox + w * 0.65, y: oy + h * 0.17), control1: CGPoint(x: ox + w * 0.54, y: oy + h * 0.08), control2: CGPoint(x: ox + w * 0.58, y: oy + h * 0.10))
            ctx.strokePath()

            let diamond = CGMutablePath()
            diamond.move(to: CGPoint(x: ox + w * 0.50, y: oy + h * 0.07))
            diamond.addLine(to: CGPoint(x: ox + w * 0.53, y: oy + h * 0.11))
            diamond.addLine(to: CGPoint(x: ox + w * 0.50, y: oy + h * 0.15))
            diamond.addLine(to: CGPoint(x: ox + w * 0.47, y: oy + h * 0.11))
            diamond.closeSubpath()
            ctx.addPath(diamond)
            ctx.setFillColor(color.cgColor)
            ctx.fillPath()
            ctx.addPath(diamond)
            ctx.setStrokeColor(UIColor.white.cgColor)
            ctx.setLineWidth(max(1.2, w * 0.006))
            ctx.strokePath()
        default:
            break
        }
        ctx.restoreGState()
    }

    // MARK: - Robes (Exact ADR Shapes)
    static func drawRobe(id: String, color: UIColor, in ctx: CGContext, rect: CGRect) {
        let w = rect.width
        let h = rect.height
        let ox = rect.minX
        let oy = rect.minY
        ctx.saveGState()

        switch id {
        case "robe_cloud_cape":
            let gold = PastelPalette.butterDark.uiColor.cgColor
            let leftCape = CGMutablePath()
            leftCape.move(to: CGPoint(x: ox + w * 0.33, y: oy + h * 0.47))
            leftCape.addCurve(to: CGPoint(x: ox + w * 0.25, y: oy + h * 0.78), control1: CGPoint(x: ox + w * 0.22, y: oy + h * 0.55), control2: CGPoint(x: ox + w * 0.20, y: oy + h * 0.70))
            leftCape.addCurve(to: CGPoint(x: ox + w * 0.36, y: oy + h * 0.72), control1: CGPoint(x: ox + w * 0.29, y: oy + h * 0.79), control2: CGPoint(x: ox + w * 0.34, y: oy + h * 0.76))
            leftCape.addCurve(to: CGPoint(x: ox + w * 0.36, y: oy + h * 0.48), control1: CGPoint(x: ox + w * 0.32, y: oy + h * 0.64), control2: CGPoint(x: ox + w * 0.34, y: oy + h * 0.54))
            leftCape.closeSubpath()

            let rightCape = CGMutablePath()
            rightCape.move(to: CGPoint(x: ox + w * 0.67, y: oy + h * 0.47))
            rightCape.addCurve(to: CGPoint(x: ox + w * 0.75, y: oy + h * 0.78), control1: CGPoint(x: ox + w * 0.78, y: oy + h * 0.55), control2: CGPoint(x: ox + w * 0.80, y: oy + h * 0.70))
            rightCape.addCurve(to: CGPoint(x: ox + w * 0.64, y: oy + h * 0.72), control1: CGPoint(x: ox + w * 0.71, y: oy + h * 0.79), control2: CGPoint(x: ox + w * 0.66, y: oy + h * 0.76))
            rightCape.addCurve(to: CGPoint(x: ox + w * 0.64, y: oy + h * 0.48), control1: CGPoint(x: ox + w * 0.68, y: oy + h * 0.64), control2: CGPoint(x: ox + w * 0.66, y: oy + h * 0.54))
            rightCape.closeSubpath()

            for p in [leftCape, rightCape] {
                ctx.addPath(p)
                ctx.setFillColor(color.cgColor)
                ctx.fillPath()
                ctx.addPath(p)
                ctx.setStrokeColor(gold)
                ctx.setLineWidth(max(1.8, w * 0.008))
                ctx.strokePath()
            }
            ctx.setFillColor(UIColor.white.cgColor)
            let pr = w * 0.024
            for i in 0..<5 {
                let t = CGFloat(i) / 4.0
                let cx = ox + w * (0.35 + t * 0.30)
                let cy = oy + h * (0.47 + sin(t * .pi) * 0.04)
                ctx.fillEllipse(in: CGRect(x: cx - pr, y: cy - pr, width: pr * 2, height: pr * 2))
            }
            ctx.setFillColor(PastelPalette.butterWarm.uiColor.cgColor)
            ctx.addPath(DragonGeometry.starPath(center: CGPoint(x: ox + w * 0.50, y: oy + h * 0.505), outerRadius: w * 0.036, innerRadius: w * 0.016))
            ctx.fillPath()

        case "robe_pastel_dress":
            let bodice = CGMutablePath()
            bodice.move(to: CGPoint(x: ox + w * 0.37, y: oy + h * 0.52))
            bodice.addCurve(to: CGPoint(x: ox + w * 0.63, y: oy + h * 0.52), control1: CGPoint(x: ox + w * 0.43, y: oy + h * 0.54), control2: CGPoint(x: ox + w * 0.57, y: oy + h * 0.54))
            bodice.addLine(to: CGPoint(x: ox + w * 0.65, y: oy + h * 0.62))
            bodice.addLine(to: CGPoint(x: ox + w * 0.35, y: oy + h * 0.62))
            bodice.closeSubpath()

            let skirt = CGMutablePath()
            skirt.move(to: CGPoint(x: ox + w * 0.35, y: oy + h * 0.62))
            skirt.addCurve(to: CGPoint(x: ox + w * 0.27, y: oy + h * 0.79), control1: CGPoint(x: ox + w * 0.22, y: oy + h * 0.66), control2: CGPoint(x: ox + w * 0.20, y: oy + h * 0.77))
            skirt.addCurve(to: CGPoint(x: ox + w * 0.73, y: oy + h * 0.79), control1: CGPoint(x: ox + w * 0.40, y: oy + h * 0.81), control2: CGPoint(x: ox + w * 0.60, y: oy + h * 0.81))
            skirt.addCurve(to: CGPoint(x: ox + w * 0.65, y: oy + h * 0.62), control1: CGPoint(x: ox + w * 0.78, y: oy + h * 0.77), control2: CGPoint(x: ox + w * 0.80, y: oy + h * 0.66))
            skirt.closeSubpath()

            ctx.setFillColor(color.cgColor)
            ctx.addPath(bodice); ctx.fillPath()
            ctx.addPath(skirt); ctx.fillPath()

            ctx.setFillColor(UIColor.white.withAlphaComponent(0.85).cgColor)
            let fr = w * 0.022
            for i in 0..<7 {
                let t = CGFloat(i) / 6.0
                let fx = ox + w * (0.28 + t * 0.44)
                let fy = oy + h * (0.785 + sin(t * .pi) * 0.02)
                ctx.fillEllipse(in: CGRect(x: fx - fr, y: fy - fr, width: fr * 2, height: fr * 2))
            }

            let sashRect = CGRect(x: ox + w * 0.34, y: oy + h * 0.604, width: w * 0.32, height: h * 0.032)
            let sashPath = CGPath(roundedRect: sashRect, cornerWidth: 8, cornerHeight: 8, transform: nil)
            ctx.addPath(sashPath)
            ctx.setFillColor(PastelPalette.butterYellow.uiColor.cgColor)
            ctx.fillPath()
            ctx.setFillColor(PastelPalette.roseSoft.uiColor.cgColor)
            ctx.addPath(DragonGeometry.heartPath(center: CGPoint(x: ox + w * 0.50, y: oy + h * 0.62), radius: w * 0.022))
            ctx.fillPath()

        case "robe_starry_vest":
            let leftVest = CGMutablePath()
            leftVest.move(to: CGPoint(x: ox + w * 0.35, y: oy + h * 0.50))
            leftVest.addLine(to: CGPoint(x: ox + w * 0.30, y: oy + h * 0.73))
            leftVest.addLine(to: CGPoint(x: ox + w * 0.43, y: oy + h * 0.71))
            leftVest.addLine(to: CGPoint(x: ox + w * 0.42, y: oy + h * 0.56))
            leftVest.closeSubpath()

            let rightVest = CGMutablePath()
            rightVest.move(to: CGPoint(x: ox + w * 0.65, y: oy + h * 0.50))
            rightVest.addLine(to: CGPoint(x: ox + w * 0.70, y: oy + h * 0.73))
            rightVest.addLine(to: CGPoint(x: ox + w * 0.57, y: oy + h * 0.71))
            rightVest.addLine(to: CGPoint(x: ox + w * 0.58, y: oy + h * 0.56))
            rightVest.closeSubpath()

            for v in [leftVest, rightVest] {
                ctx.addPath(v)
                ctx.setFillColor(color.cgColor)
                ctx.fillPath()
                ctx.addPath(v)
                ctx.setStrokeColor(PastelPalette.butterWarm.uiColor.cgColor)
                ctx.setLineWidth(max(1.8, w * 0.008))
                ctx.strokePath()
            }
            ctx.setFillColor(PastelPalette.butterYellow.uiColor.cgColor)
            let br = w * 0.016
            ctx.fillEllipse(in: CGRect(x: ox + w * 0.39 - br, y: oy + h * 0.60 - br, width: br * 2, height: br * 2))
            ctx.fillEllipse(in: CGRect(x: ox + w * 0.38 - br, y: oy + h * 0.66 - br, width: br * 2, height: br * 2))

        case "robe_night_gown":
            let gown = CGMutablePath()
            gown.move(to: CGPoint(x: ox + w * 0.35, y: oy + h * 0.50))
            gown.addCurve(to: CGPoint(x: ox + w * 0.30, y: oy + h * 0.80), control1: CGPoint(x: ox + w * 0.28, y: oy + h * 0.60), control2: CGPoint(x: ox + w * 0.25, y: oy + h * 0.74))
            gown.addLine(to: CGPoint(x: ox + w * 0.70, y: oy + h * 0.80))
            gown.addCurve(to: CGPoint(x: ox + w * 0.65, y: oy + h * 0.50), control1: CGPoint(x: ox + w * 0.75, y: oy + h * 0.74), control2: CGPoint(x: ox + w * 0.72, y: oy + h * 0.60))
            gown.closeSubpath()
            ctx.addPath(gown)
            ctx.setFillColor(color.cgColor)
            ctx.fillPath()

            ctx.setStrokeColor(PastelPalette.butterYellow.uiColor.cgColor)
            ctx.setLineWidth(max(1.8, w * 0.008))
            ctx.move(to: CGPoint(x: ox + w * 0.37, y: oy + h * 0.50))
            ctx.addLine(to: CGPoint(x: ox + w * 0.60, y: oy + h * 0.63))
            ctx.strokePath()

            let obiRect = CGRect(x: ox + w * 0.32, y: oy + h * 0.605, width: w * 0.36, height: h * 0.05)
            let obiPath = CGPath(roundedRect: obiRect, cornerWidth: 6, cornerHeight: 6, transform: nil)
            ctx.addPath(obiPath)
            ctx.setFillColor(PastelPalette.lavenderPurple.uiColor.cgColor)
            ctx.fillPath()
            ctx.addPath(obiPath)
            ctx.strokePath()
        default:
            break
        }
        ctx.restoreGState()
    }

    // MARK: - Scarves & Necklaces (Exact ADR Shapes)
    static func drawScarf(id: String, color: UIColor, in ctx: CGContext, rect: CGRect) {
        let w = rect.width
        let h = rect.height
        let ox = rect.minX
        let oy = rect.minY
        ctx.saveGState()

        switch id {
        case "scarf_ribbon":
            let cx = ox + w * 0.50
            let cy = oy + h * 0.46
            let leftLoop = CGMutablePath()
            leftLoop.move(to: CGPoint(x: cx, y: cy))
            leftLoop.addCurve(to: CGPoint(x: ox + w * 0.40, y: oy + h * 0.47), control1: CGPoint(x: ox + w * 0.44, y: oy + h * 0.41), control2: CGPoint(x: ox + w * 0.38, y: oy + h * 0.42))
            leftLoop.addCurve(to: CGPoint(x: cx, y: cy), control1: CGPoint(x: ox + w * 0.42, y: oy + h * 0.51), control2: CGPoint(x: ox + w * 0.46, y: oy + h * 0.49))
            leftLoop.closeSubpath()

            let rightLoop = CGMutablePath()
            rightLoop.move(to: CGPoint(x: cx, y: cy))
            rightLoop.addCurve(to: CGPoint(x: ox + w * 0.60, y: oy + h * 0.47), control1: CGPoint(x: ox + w * 0.56, y: oy + h * 0.41), control2: CGPoint(x: ox + w * 0.62, y: oy + h * 0.42))
            rightLoop.addCurve(to: CGPoint(x: cx, y: cy), control1: CGPoint(x: ox + w * 0.58, y: oy + h * 0.51), control2: CGPoint(x: ox + w * 0.54, y: oy + h * 0.49))
            rightLoop.closeSubpath()

            ctx.setFillColor(color.cgColor)
            ctx.addPath(leftLoop); ctx.fillPath()
            ctx.addPath(rightLoop); ctx.fillPath()

            let knotR = w * 0.030
            ctx.fillEllipse(in: CGRect(x: cx - knotR, y: cy - knotR, width: knotR * 2, height: knotR * 2))
            ctx.setStrokeColor(PastelPalette.strokeSoft.withAlpha(0.35).uiColor.cgColor)
            ctx.setLineWidth(max(1.5, w * 0.007))
            ctx.addPath(leftLoop); ctx.strokePath()
            ctx.addPath(rightLoop); ctx.strokePath()
            ctx.strokeEllipse(in: CGRect(x: cx - knotR, y: cy - knotR, width: knotR * 2, height: knotR * 2))

        case "scarf_cloud_boa":
            let wrapRect = CGRect(x: ox + w * 0.33, y: oy + h * 0.432, width: w * 0.34, height: h * 0.065)
            let wrap = CGPath(roundedRect: wrapRect, cornerWidth: w * 0.04, cornerHeight: w * 0.04, transform: nil)
            let tail = CGMutablePath()
            tail.move(to: CGPoint(x: ox + w * 0.56, y: oy + h * 0.48))
            tail.addLine(to: CGPoint(x: ox + w * 0.55, y: oy + h * 0.64))
            tail.addLine(to: CGPoint(x: ox + w * 0.64, y: oy + h * 0.64))
            tail.addLine(to: CGPoint(x: ox + w * 0.63, y: oy + h * 0.48))
            tail.closeSubpath()

            ctx.setFillColor(color.cgColor)
            ctx.addPath(tail); ctx.fillPath()
            ctx.addPath(wrap); ctx.fillPath()
            ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.8).cgColor)
            ctx.setLineWidth(max(1.5, w * 0.007))
            ctx.addPath(tail); ctx.strokePath()
            ctx.addPath(wrap); ctx.strokePath()

            ctx.setStrokeColor(UIColor.white.cgColor)
            ctx.setLineCap(.round)
            for i in 0..<4 {
                let fx = ox + w * (0.56 + CGFloat(i) * 0.024)
                ctx.move(to: CGPoint(x: fx, y: oy + h * 0.64))
                ctx.addLine(to: CGPoint(x: fx, y: oy + h * 0.67))
                ctx.strokePath()
            }

        case "scarf_bell_choker":
            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(max(3.0, w * 0.016))
            ctx.setLineCap(.round)
            ctx.move(to: CGPoint(x: ox + w * 0.36, y: oy + h * 0.455))
            ctx.addQuadCurve(to: CGPoint(x: ox + w * 0.64, y: oy + h * 0.455), control: CGPoint(x: ox + w * 0.50, y: oy + h * 0.48))
            ctx.strokePath()

            let br = w * 0.038
            let bellRect = CGRect(x: ox + w * 0.50 - br, y: oy + h * 0.50 - br, width: br * 2, height: br * 2)
            ctx.setFillColor(PastelPalette.butterWarm.uiColor.cgColor)
            ctx.fillEllipse(in: bellRect)
            ctx.setStrokeColor(PastelPalette.butterDark.uiColor.cgColor)
            ctx.setLineWidth(max(1.5, w * 0.007))
            ctx.strokeEllipse(in: bellRect)

        case "scarf_pearl_necklace":
            for i in 0..<9 {
                let t = CGFloat(i) / 8.0
                let px = ox + w * (0.36 + t * 0.28)
                let py = oy + h * (0.455 + sin(t * .pi) * 0.05)
                let pr = w * (0.016 + sin(t * .pi) * 0.010)
                let pearlRect = CGRect(x: px - pr, y: py - pr, width: pr * 2, height: pr * 2)
                ctx.setFillColor(UIColor(red: 1.0, green: 0.992, blue: 0.96, alpha: 1.0).cgColor)
                ctx.fillEllipse(in: pearlRect)
                ctx.setStrokeColor(PastelPalette.strokeSoft.withAlpha(0.25).uiColor.cgColor)
                ctx.setLineWidth(1.0)
                ctx.strokeEllipse(in: pearlRect)
            }
            ctx.setFillColor(color.cgColor)
            ctx.addPath(DragonGeometry.heartPath(center: CGPoint(x: ox + w * 0.50, y: oy + h * 0.525), radius: w * 0.022))
            ctx.fillPath()
        default:
            break
        }
        ctx.restoreGState()
    }

    // MARK: - Glasses & Masks
    static func drawGlasses(id: String, color: UIColor, in ctx: CGContext, rect: CGRect) {
        let w = rect.width
        let h = rect.height
        let ox = rect.minX
        let oy = rect.minY
        let eyeY = oy + h * 0.33
        let leftX = ox + w * 0.42
        let rightX = ox + w * 0.58
        ctx.saveGState()

        switch id {
        case "glasses_star":
            let r = w * 0.082
            let lStar = DragonGeometry.starPath(center: CGPoint(x: leftX, y: eyeY), outerRadius: r, innerRadius: r * 0.48)
            let rStar = DragonGeometry.starPath(center: CGPoint(x: rightX, y: eyeY), outerRadius: r, innerRadius: r * 0.48)
            ctx.setFillColor(color.withAlphaComponent(0.35).cgColor)
            ctx.addPath(lStar); ctx.fillPath()
            ctx.addPath(rStar); ctx.fillPath()

            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(max(2.2, w * 0.011))
            ctx.setLineJoin(.round)
            ctx.addPath(lStar); ctx.strokePath()
            ctx.addPath(rStar); ctx.strokePath()
            ctx.move(to: CGPoint(x: leftX + w * 0.05, y: eyeY))
            ctx.addLine(to: CGPoint(x: rightX - w * 0.05, y: eyeY))
            ctx.strokePath()

        case "glasses_heart":
            let r = w * 0.075
            let lHeart = DragonGeometry.heartPath(center: CGPoint(x: leftX, y: eyeY), radius: r)
            let rHeart = DragonGeometry.heartPath(center: CGPoint(x: rightX, y: eyeY), radius: r)
            ctx.setFillColor(color.withAlphaComponent(0.40).cgColor)
            ctx.addPath(lHeart); ctx.fillPath()
            ctx.addPath(rHeart); ctx.fillPath()

            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(max(2.2, w * 0.011))
            ctx.addPath(lHeart); ctx.strokePath()
            ctx.addPath(rHeart); ctx.strokePath()
            ctx.move(to: CGPoint(x: leftX + w * 0.045, y: eyeY - h * 0.01))
            ctx.addLine(to: CGPoint(x: rightX - w * 0.045, y: eyeY - h * 0.01))
            ctx.strokePath()

        case "glasses_cloud_mask":
            let mask = CGMutablePath()
            mask.move(to: CGPoint(x: ox + w * 0.28, y: oy + h * 0.27))
            mask.addCurve(to: CGPoint(x: ox + w * 0.50, y: oy + h * 0.34), control1: CGPoint(x: ox + w * 0.36, y: oy + h * 0.29), control2: CGPoint(x: ox + w * 0.44, y: oy + h * 0.32))
            mask.addCurve(to: CGPoint(x: ox + w * 0.72, y: oy + h * 0.27), control1: CGPoint(x: ox + w * 0.56, y: oy + h * 0.32), control2: CGPoint(x: ox + w * 0.64, y: oy + h * 0.29))
            mask.addCurve(to: CGPoint(x: ox + w * 0.50, y: oy + h * 0.37), control1: CGPoint(x: ox + w * 0.70, y: oy + h * 0.38), control2: CGPoint(x: ox + w * 0.62, y: oy + h * 0.40))
            mask.addCurve(to: CGPoint(x: ox + w * 0.28, y: oy + h * 0.27), control1: CGPoint(x: ox + w * 0.38, y: oy + h * 0.40), control2: CGPoint(x: ox + w * 0.30, y: oy + h * 0.38))
            mask.closeSubpath()

            ctx.addPath(mask)
            ctx.setFillColor(color.withAlphaComponent(0.88).cgColor)
            ctx.fillPath()
            ctx.addPath(mask)
            ctx.setStrokeColor(PastelPalette.butterYellow.uiColor.cgColor)
            ctx.setLineWidth(max(1.8, w * 0.008))
            ctx.strokePath()

            let gr = w * 0.016
            ctx.setFillColor(PastelPalette.butterWarm.uiColor.cgColor)
            ctx.fillEllipse(in: CGRect(x: ox + w * 0.50 - gr, y: oy + h * 0.32 - gr, width: gr * 2, height: gr * 2))
        default:
            break
        }
        ctx.restoreGState()
    }

    // MARK: - Back Wings & Halo
    static func drawBackWingsDeco(id: String, color: UIColor, in ctx: CGContext, rect: CGRect) {
        let w = rect.width
        let h = rect.height
        let ox = rect.minX
        let oy = rect.minY
        ctx.saveGState()

        switch id {
        case "wings_sparkle":
            let leftTop = CGMutablePath()
            leftTop.move(to: CGPoint(x: ox + w * 0.30, y: oy + h * 0.40))
            leftTop.addCurve(to: CGPoint(x: ox + w * 0.08, y: oy + h * 0.08), control1: CGPoint(x: ox + w * 0.14, y: oy + h * 0.24), control2: CGPoint(x: ox + w * 0.04, y: oy + h * 0.10))
            leftTop.addCurve(to: CGPoint(x: ox + w * 0.28, y: oy + h * 0.34), control1: CGPoint(x: ox + w * 0.16, y: oy + h * 0.07), control2: CGPoint(x: ox + w * 0.22, y: oy + h * 0.20))
            leftTop.closeSubpath()

            let rightTop = CGMutablePath()
            rightTop.move(to: CGPoint(x: ox + w * 0.70, y: oy + h * 0.40))
            rightTop.addCurve(to: CGPoint(x: ox + w * 0.92, y: oy + h * 0.08), control1: CGPoint(x: ox + w * 0.86, y: oy + h * 0.24), control2: CGPoint(x: ox + w * 0.96, y: oy + h * 0.10))
            rightTop.addCurve(to: CGPoint(x: ox + w * 0.72, y: oy + h * 0.34), control1: CGPoint(x: ox + w * 0.84, y: oy + h * 0.07), control2: CGPoint(x: ox + w * 0.78, y: oy + h * 0.20))
            rightTop.closeSubpath()

            for p in [leftTop, rightTop] {
                ctx.addPath(p)
                ctx.setFillColor(color.withAlphaComponent(0.55).cgColor)
                ctx.fillPath()
                ctx.addPath(p)
                ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.85).cgColor)
                ctx.setLineWidth(max(1.5, w * 0.006))
                ctx.strokePath()
            }

        case "wings_feather":
            let leftWing = CGMutablePath()
            leftWing.move(to: CGPoint(x: ox + w * 0.30, y: oy + h * 0.45))
            leftWing.addCurve(to: CGPoint(x: ox + w * 0.04, y: oy + h * 0.14), control1: CGPoint(x: ox + w * 0.18, y: oy + h * 0.30), control2: CGPoint(x: ox + w * 0.06, y: oy + h * 0.18))
            leftWing.addCurve(to: CGPoint(x: ox + w * 0.06, y: oy + h * 0.26), control1: CGPoint(x: ox + w * 0.10, y: oy + h * 0.18), control2: CGPoint(x: ox + w * 0.12, y: oy + h * 0.28))
            leftWing.addCurve(to: CGPoint(x: ox + w * 0.10, y: oy + h * 0.44), control1: CGPoint(x: ox + w * 0.12, y: oy + h * 0.32), control2: CGPoint(x: ox + w * 0.14, y: oy + h * 0.40))
            leftWing.addCurve(to: CGPoint(x: ox + w * 0.30, y: oy + h * 0.48), control1: CGPoint(x: ox + w * 0.16, y: oy + h * 0.48), control2: CGPoint(x: ox + w * 0.24, y: oy + h * 0.52))
            leftWing.closeSubpath()

            let rightWing = CGMutablePath()
            rightWing.move(to: CGPoint(x: ox + w * 0.70, y: oy + h * 0.45))
            rightWing.addCurve(to: CGPoint(x: ox + w * 0.96, y: oy + h * 0.14), control1: CGPoint(x: ox + w * 0.82, y: oy + h * 0.30), control2: CGPoint(x: ox + w * 0.94, y: oy + h * 0.18))
            rightWing.addCurve(to: CGPoint(x: ox + w * 0.94, y: oy + h * 0.26), control1: CGPoint(x: ox + w * 0.90, y: oy + h * 0.18), control2: CGPoint(x: ox + w * 0.88, y: oy + h * 0.28))
            rightWing.addCurve(to: CGPoint(x: ox + w * 0.90, y: oy + h * 0.44), control1: CGPoint(x: ox + w * 0.88, y: oy + h * 0.32), control2: CGPoint(x: ox + w * 0.86, y: oy + h * 0.40))
            rightWing.addCurve(to: CGPoint(x: ox + w * 0.70, y: oy + h * 0.48), control1: CGPoint(x: ox + w * 0.84, y: oy + h * 0.48), control2: CGPoint(x: ox + w * 0.76, y: oy + h * 0.52))
            rightWing.closeSubpath()

            for p in [leftWing, rightWing] {
                ctx.addPath(p)
                ctx.setFillColor(color.withAlphaComponent(0.65).cgColor)
                ctx.fillPath()
                ctx.addPath(p)
                ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.9).cgColor)
                ctx.setLineWidth(max(1.5, w * 0.007))
                ctx.strokePath()
            }

        case "wings_rainbow_bow":
            ctx.setFillColor(color.cgColor)
            let leftWingBow = CGRect(x: ox + w * 0.18, y: oy + h * 0.42, width: w * 0.14, height: h * 0.10)
            let rightWingBow = CGRect(x: ox + w * 0.68, y: oy + h * 0.42, width: w * 0.14, height: h * 0.10)
            ctx.fillEllipse(in: leftWingBow)
            ctx.fillEllipse(in: rightWingBow)
            ctx.setStrokeColor(UIColor.white.cgColor)
            ctx.setLineWidth(max(1.5, w * 0.006))
            ctx.strokeEllipse(in: leftWingBow)
            ctx.strokeEllipse(in: rightWingBow)

        default:
            break
        }
        ctx.restoreGState()
    }

    static func drawHalo(color: UIColor, in ctx: CGContext, rect: CGRect) {
        let w = rect.width
        let h = rect.height
        let ox = rect.minX
        let oy = rect.minY
        ctx.saveGState()
        let haloRect = CGRect(x: ox + w * 0.36, y: oy + h * 0.038, width: w * 0.28, height: h * 0.065)
        ctx.setStrokeColor(color.withAlphaComponent(0.4).cgColor)
        ctx.setLineWidth(max(4.0, w * 0.025))
        ctx.strokeEllipse(in: haloRect)
        ctx.setStrokeColor(PastelPalette.butterWarm.uiColor.cgColor)
        ctx.setLineWidth(max(2.0, w * 0.011))
        ctx.strokeEllipse(in: haloRect)
        ctx.restoreGState()
    }
}
