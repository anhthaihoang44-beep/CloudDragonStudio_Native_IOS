import CoreGraphics
import SwiftUI

struct DragonView: View {
    let character: CloudDragonCharacter
    let reduceMotion: Bool
    var catalog: [CatalogItem] = CatalogLoader.fallbackCatalog
    var zonePaintImages: [DragonZone: CGImage] = [:]
    var highlightedZone: DragonZone? = nil
    var showSparkles: Bool = true
    var animateIdle: Bool = true

    @State private var floatUp = false

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            ZStack {
                Canvas { graphicsContext, size in
                    let canvasSide = min(size.width, size.height)
                    let drawRect = CGRect(
                        x: (size.width - canvasSide) * 0.5,
                        y: (size.height - canvasSide) * 0.5,
                        width: canvasSide,
                        height: canvasSide
                    )
                    graphicsContext.withCGContext { cgCtx in
                        CoreGraphicsDragonDrawer.drawDragon(
                            in: cgCtx,
                            rect: drawRect,
                            character: character,
                            catalog: catalog,
                            zonePaintImages: zonePaintImages,
                            highlightedZone: highlightedZone
                        )
                    }
                }
                .offset(y: (!animateIdle || reduceMotion) ? 0 : (floatUp ? -4 : 4))
                .animation(
                    (!animateIdle || reduceMotion) ? nil : .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: floatUp
                )

                if showSparkles {
                    Image(systemName: "sparkle")
                        .font(.system(size: max(12, side * 0.075), weight: .bold))
                        .foregroundStyle(PastelPalette.butterDark.swiftUIColor.opacity(0.85))
                        .offset(x: -side * 0.34, y: -side * 0.30)
                }
            }
            .onAppear {
                if animateIdle && !reduceMotion {
                    floatUp = true
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(character.name)
    }
}
