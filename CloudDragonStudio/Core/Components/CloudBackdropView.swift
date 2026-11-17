import SwiftUI

struct CloudBackdropView: View {
    let reduceMotion: Bool
    @State private var drift = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [
                        PastelPalette.skyTop.swiftUIColor,
                        PastelPalette.skyMid.swiftUIColor,
                        PastelPalette.skyBottom.swiftUIColor
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Soft decorative clouds that respect Reduce Motion
                Group {
                    SoftPuffCloud()
                        .fill(.white.opacity(0.68))
                        .frame(width: max(140, geo.size.width * 0.24), height: 68)
                        .position(x: geo.size.width * 0.16, y: geo.size.height * 0.14)
                        .offset(x: reduceMotion ? 0 : (drift ? 14 : -14))

                    SoftPuffCloud()
                        .fill(.white.opacity(0.60))
                        .frame(width: max(160, geo.size.width * 0.28), height: 76)
                        .position(x: geo.size.width * 0.84, y: geo.size.height * 0.20)
                        .offset(x: reduceMotion ? 0 : (drift ? -16 : 16))

                    SoftPuffCloud()
                        .fill(.white.opacity(0.50))
                        .frame(width: max(180, geo.size.width * 0.30), height: 82)
                        .position(x: geo.size.width * 0.50, y: geo.size.height * 0.88)
                        .offset(x: reduceMotion ? 0 : (drift ? 10 : -10))
                }
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 5.5).repeatForever(autoreverses: true),
                    value: drift
                )
            }
            .onAppear {
                if !reduceMotion {
                    drift = true
                }
            }
        }
        .accessibilityHidden(true)
    }
}

struct SoftPuffCloud: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.addEllipse(in: CGRect(x: 0, y: h * 0.32, width: w * 0.42, height: h * 0.65))
        path.addEllipse(in: CGRect(x: w * 0.22, y: 0, width: w * 0.56, height: h * 0.92))
        path.addEllipse(in: CGRect(x: w * 0.56, y: h * 0.28, width: w * 0.44, height: h * 0.68))
        return path
    }
}
