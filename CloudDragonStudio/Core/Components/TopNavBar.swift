import SwiftUI

struct TopNavBar: View {
    let title: String
    let backLabel: String
    let showBackButton: Bool
    let onBack: (() -> Void)?
    let trailingContent: AnyView?

    init(
        title: String,
        backLabel: String = "Home",
        showBackButton: Bool = true,
        onBack: (() -> Void)? = nil,
        trailingContent: AnyView? = nil
    ) {
        self.title = title
        self.backLabel = backLabel
        self.showBackButton = showBackButton
        self.onBack = onBack
        self.trailingContent = trailingContent
    }

    var body: some View {
        HStack(spacing: 12) {
            if showBackButton, let onBack {
                Button(action: onBack) {
                    HStack(spacing: 6) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text(backLabel)
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                    .padding(.horizontal, 14)
                    .frame(minWidth: 48, minHeight: 48)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.92))
                            .shadow(color: PastelPalette.lavenderDeep.swiftUIColor.opacity(0.18), radius: 6, y: 3)
                    )
                }
                .accessibilityIdentifier("nav.backHome")
                .accessibilityLabel(backLabel)
            }

            Spacer(minLength: 8)

            Text(title)
                .font(.system(.title3, design: .rounded).weight(.heavy))
                .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 8)

            if let trailingContent {
                trailingContent
            } else if showBackButton {
                // Balance layout symmetry away from primary bottom actions
                Color.clear
                    .frame(width: 48, height: 48)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }
}
