import SwiftUI

struct PetGardenView: View {
    var body: some View {
        AreaStubView(
            titleKey: "area.pets",
            descKey: "area.pets.desc",
            symbol: "pawprint.fill",
            accent: PastelPalette.peach
        )
    }
}
