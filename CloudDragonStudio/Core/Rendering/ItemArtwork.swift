import CoreGraphics
import SwiftUI

struct ItemThumbnailCanvas: View {
    let item: CatalogItem
    let color: CodableColor

    var body: some View {
        Canvas { graphicsContext, size in
            let side = min(size.width, size.height)
            let rect = CGRect(
                x: (size.width - side) * 0.5,
                y: (size.height - side) * 0.5,
                width: side,
                height: side
            )
            graphicsContext.withCGContext { cgCtx in
                let uiColor = color.uiColor
                switch item.category {
                case .hat:
                    // Scale and center crown/hat area (upper 0.05..0.28) nicely inside thumbnail
                    cgCtx.saveGState()
                    cgCtx.translateBy(x: rect.minX - side * 0.62, y: rect.minY - side * 0.05)
                    cgCtx.scaleBy(x: 2.25, y: 2.25)
                    CoreGraphicsDragonDrawer.drawHat(id: item.id, color: uiColor, in: cgCtx, rect: CGRect(x: 0, y: 0, width: side, height: side))
                    cgCtx.restoreGState()

                case .robe:
                    cgCtx.saveGState()
                    cgCtx.translateBy(x: rect.minX - side * 0.42, y: rect.minY - side * 0.82)
                    cgCtx.scaleBy(x: 1.85, y: 1.85)
                    CoreGraphicsDragonDrawer.drawRobe(id: item.id, color: uiColor, in: cgCtx, rect: CGRect(x: 0, y: 0, width: side, height: side))
                    cgCtx.restoreGState()

                case .scarf:
                    cgCtx.saveGState()
                    cgCtx.translateBy(x: rect.minX - side * 0.65, y: rect.minY - side * 0.68)
                    cgCtx.scaleBy(x: 2.30, y: 2.30)
                    CoreGraphicsDragonDrawer.drawScarf(id: item.id, color: uiColor, in: cgCtx, rect: CGRect(x: 0, y: 0, width: side, height: side))
                    cgCtx.restoreGState()

                case .glasses:
                    cgCtx.saveGState()
                    cgCtx.translateBy(x: rect.minX - side * 0.65, y: rect.minY - side * 0.35)
                    cgCtx.scaleBy(x: 2.30, y: 2.30)
                    CoreGraphicsDragonDrawer.drawGlasses(id: item.id, color: uiColor, in: cgCtx, rect: CGRect(x: 0, y: 0, width: side, height: side))
                    cgCtx.restoreGState()

                case .wingsDeco:
                    if item.id == "wings_halo" {
                        cgCtx.saveGState()
                        cgCtx.translateBy(x: rect.minX - side * 0.62, y: rect.minY + side * 0.25)
                        cgCtx.scaleBy(x: 2.25, y: 2.25)
                        CoreGraphicsDragonDrawer.drawHalo(color: uiColor, in: cgCtx, rect: CGRect(x: 0, y: 0, width: side, height: side))
                        cgCtx.restoreGState()
                    } else {
                        cgCtx.saveGState()
                        cgCtx.translateBy(x: rect.minX - side * 0.05, y: rect.minY - side * 0.05)
                        cgCtx.scaleBy(x: 1.1, y: 1.1)
                        CoreGraphicsDragonDrawer.drawBackWingsDeco(id: item.id, color: uiColor, in: cgCtx, rect: CGRect(x: 0, y: 0, width: side, height: side))
                        cgCtx.restoreGState()
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }
}
