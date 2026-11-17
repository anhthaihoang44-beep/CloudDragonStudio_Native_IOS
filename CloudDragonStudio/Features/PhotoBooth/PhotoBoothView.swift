import SwiftUI

struct PhotoBoothView: View {
    var body: some View {
        AreaStubView(
            titleKey: "area.photo",
            descKey: "area.photo.desc",
            symbol: "camera.fill",
            accent: PastelPalette.lavender
        )
    }
}
