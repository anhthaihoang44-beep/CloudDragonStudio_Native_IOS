import SwiftUI

struct TopNavBar: View {
    let title: String
    var subtitle: String? = nil
    let backLabel: String
    let showBackButton: Bool
    let onBack: (() -> Void)?
    let showSoundButton: Bool
    let trailingContent: AnyView?

    @EnvironmentObject private var audio: AudioService

    init(
        title: String,
        subtitle: String? = nil,
        backLabel: String = "Home",
        showBackButton: Bool = true,
        showSoundButton: Bool = true,
        onBack: (() -> Void)? = nil,
        trailingContent: AnyView? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.backLabel = backLabel
        self.showBackButton = showBackButton
        self.showSoundButton = showSoundButton
        self.onBack = onBack
        self.trailingContent = trailingContent
    }

    var body: some View {
        HStack(spacing: 8) {
            if showBackButton, let onBack {
                Button(action: {
                    audio.playPop()
                    onBack()
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 15, weight: .bold))
                        Text(backLabel)
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                    .padding(.horizontal, 12)
                    .frame(minWidth: 48, minHeight: 46)
                    .fixedSize(horizontal: true, vertical: false)
                    .background(
                        Capsule()
                            .fill(PastelPalette.butterYellow.swiftUIColor)
                            .overlay(Capsule().stroke(.white, lineWidth: 2))
                            .shadow(color: PastelPalette.butterDark.swiftUIColor.opacity(0.28), radius: 5, y: 3)
                    )
                }
                .layoutPriority(2)
                .accessibilityIdentifier("nav.backHome")
                .accessibilityLabel(backLabel)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(.headline, design: .rounded).weight(.heavy))
                    .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(.caption2, design: .rounded).weight(.semibold))
                        .foregroundStyle(PastelPalette.textMuted.swiftUIColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
            }

            Spacer(minLength: 4)

            if let trailingContent {
                trailingContent
                    .layoutPriority(1)
            }

            if showSoundButton {
                Button {
                    audio.toggleSound()
                } label: {
                    Image(systemName: audio.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                        .frame(width: 46, height: 46)
                        .background(
                            Circle()
                                .fill(audio.isSoundEnabled ? PastelPalette.mintGreen.swiftUIColor : PastelPalette.cardBorder.swiftUIColor)
                                .overlay(Circle().stroke(.white, lineWidth: 2))
                                .shadow(color: Color.black.opacity(0.08), radius: 4, y: 2)
                        )
                }
                .layoutPriority(1)
                .accessibilityIdentifier("nav.soundToggle")
                .accessibilityLabel(audio.isSoundEnabled ? "Sound On" : "Sound Off")
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 6)
        .padding(.bottom, 4)
    }
}
