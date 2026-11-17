import SwiftUI

struct ColorSelectorCard: View {
    @Binding var selectedColor: CodableColor
    var onColorSelected: ((CodableColor) -> Void)? = nil

    @State private var showCustomHue = false
    @State private var hueValue: Double = 0.5

    var body: some View {
        VStack(spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(PastelPalette.kidSwatches.enumerated()), id: \.offset) { idx, swatch in
                        let isSelected = selectedColor == swatch
                        Button {
                            selectedColor = swatch
                            hueValue = swatch.hueComponent
                            onColorSelected?(swatch)
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(swatch.swiftUIColor)
                                    .frame(width: isSelected ? 48 : 42, height: isSelected ? 48 : 42)
                                    .overlay(
                                        Circle()
                                            .stroke(isSelected ? PastelPalette.textDark.swiftUIColor : .white, lineWidth: isSelected ? 3.5 : 2.5)
                                    )
                                    .shadow(color: swatch.swiftUIColor.opacity(0.35), radius: isSelected ? 7 : 3, y: 3)
                                if isSelected {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(minWidth: 44, minHeight: 44)
                        }
                        .accessibilityIdentifier("color.swatch.\(idx)")
                        .accessibilityLabel("Color \(idx + 1)")
                    }

                    // Custom Hue Toggle Wheel matching ADR ColorSelector
                    Button {
                        showCustomHue.toggle()
                        hueValue = selectedColor.hueComponent
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    AngularGradient(
                                        colors: [
                                            PastelPalette.roseSoft.swiftUIColor,
                                            PastelPalette.butterYellow.swiftUIColor,
                                            PastelPalette.mintGreen.swiftUIColor,
                                            PastelPalette.skyBlue.swiftUIColor,
                                            PastelPalette.lavenderPurple.swiftUIColor,
                                            PastelPalette.roseSoft.swiftUIColor
                                        ],
                                        center: .center
                                    )
                                )
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(showCustomHue ? PastelPalette.textDark.swiftUIColor : .white, lineWidth: 3)
                                )
                            Image(systemName: "eyedropper")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                        }
                        .frame(minWidth: 44, minHeight: 44)
                    }
                    .accessibilityIdentifier("color.customHueToggle")
                    .accessibilityLabel("Custom Hue")
                }
                .padding(.horizontal, 4)
            }

            if showCustomHue {
                HStack(spacing: 10) {
                    Image(systemName: "paintpalette.fill")
                        .foregroundStyle(PastelPalette.textMuted.swiftUIColor)
                    Slider(
                        value: Binding(
                            get: { hueValue },
                            set: { newHue in
                                hueValue = newHue
                                let next = selectedColor.shiftedHue(to: newHue, saturation: 0.48, brightness: 0.95)
                                selectedColor = next
                                onColorSelected?(next)
                            }
                        ),
                        in: 0...1
                    )
                    .tint(selectedColor.swiftUIColor)
                    .accessibilityIdentifier("color.hueSlider")
                    .accessibilityLabel("Hue Slider")
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    PastelPalette.roseSoft.swiftUIColor.opacity(0.28),
                                    PastelPalette.butterYellow.swiftUIColor.opacity(0.28),
                                    PastelPalette.mintGreen.swiftUIColor.opacity(0.28),
                                    PastelPalette.skyBlue.swiftUIColor.opacity(0.28),
                                    PastelPalette.lavenderPurple.swiftUIColor.opacity(0.28)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(PastelPalette.cloudWhite.swiftUIColor.opacity(0.95))
                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 3)
        )
    }
}
