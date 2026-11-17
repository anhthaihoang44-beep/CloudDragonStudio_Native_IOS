import StoreKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var localization: LocalizationService
    @EnvironmentObject private var audio: AudioService
    @EnvironmentObject private var purchases: PurchaseService
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.requestReview) private var requestReview

    @State private var showPrivacySheet = false
    @State private var pendingGateAction: GatedSettingsAction?

    private enum GatedSettingsAction: Identifiable {
        case privacy
        case rateApp
        case purchasePremium
        case restorePurchases

        var id: Int {
            switch self {
            case .privacy: return 0
            case .rateApp: return 1
            case .purchasePremium: return 2
            case .restorePurchases: return 3
            }
        }
    }

    private var reduceMotion: Bool {
        container.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    var body: some View {
        ZStack {
            CloudBackdropView(reduceMotion: reduceMotion)

            VStack(spacing: 12) {
                TopNavBar(
                    title: localization.text("mode.settings"),
                    backLabel: localization.text("nav.home"),
                    onBack: { router.popToHome() }
                )

                ScrollView {
                    VStack(spacing: 14) {
                        // Sound & Music Card
                        VStack(spacing: 12) {
                            Toggle(isOn: $audio.isMusicEnabled) {
                                Label(localization.text("settings.music"), systemImage: "music.note")
                                    .font(.system(.headline, design: .rounded).weight(.bold))
                            }
                            .tint(PastelPalette.mintDark.swiftUIColor)

                            Divider()

                            Toggle(isOn: $audio.isSoundEnabled) {
                                Label(localization.text("settings.sfx"), systemImage: "speaker.wave.2.fill")
                                    .font(.system(.headline, design: .rounded).weight(.bold))
                            }
                            .tint(PastelPalette.mintDark.swiftUIColor)

                            Divider()

                            Toggle(isOn: $container.reduceMotionPreference) {
                                Label(localization.text("settings.reduce_motion"), systemImage: "figure.walk.motion")
                                    .font(.system(.headline, design: .rounded).weight(.bold))
                            }
                            .tint(PastelPalette.mintDark.swiftUIColor)
                        }
                        .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(.white.opacity(0.9)))

                        // Language Switcher Card
                        VStack(alignment: .leading, spacing: 10) {
                            Text(localization.text("settings.language"))
                                .font(.system(.headline, design: .rounded).weight(.bold))
                                .foregroundStyle(PastelPalette.textDark.swiftUIColor)

                            HStack(spacing: 10) {
                                ForEach(AppLanguage.allCases) { lang in
                                    Button {
                                        audio.playPop()
                                        localization.language = lang
                                    } label: {
                                        Text(lang.displayName)
                                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                                            .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                                            .frame(maxWidth: .infinity, minHeight: 46)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                    .fill(localization.language == lang ? PastelPalette.mintGreen.swiftUIColor : PastelPalette.skyTop.swiftUIColor)
                                            )
                                    }
                                    .accessibilityIdentifier("settings.lang.\(lang.rawValue)")
                                }
                            }
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(.white.opacity(0.9)))

                        // StoreKit 2 Premium & Restore Card (behind Parental Gate)
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(PastelPalette.butterDark.swiftUIColor)
                                Text(localization.text("premium.title"))
                                    .font(.system(.headline, design: .rounded).weight(.heavy))
                                    .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                                Spacer()
                                if container.isPremium {
                                    Text(localization.text("premium.active"))
                                        .font(.system(.caption, design: .rounded).weight(.bold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(PastelPalette.mintLight.swiftUIColor))
                                }
                            }

                            Text(localization.text("premium.desc"))
                                .font(.system(.caption, design: .rounded).weight(.medium))
                                .foregroundStyle(PastelPalette.textMuted.swiftUIColor)

                            HStack(spacing: 10) {
                                if !container.isPremium {
                                    Button {
                                        pendingGateAction = .purchasePremium
                                    } label: {
                                        Text(purchases.premiumProduct?.displayPrice ?? localization.text("premium.buy_button"))
                                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                                            .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                                            .frame(maxWidth: .infinity, minHeight: 46)
                                            .background(Capsule().fill(PastelPalette.butterYellow.swiftUIColor))
                                    }
                                    .accessibilityIdentifier("settings.buyPremium")
                                }

                                Button {
                                    pendingGateAction = .restorePurchases
                                } label: {
                                    Text(localization.text("settings.restore"))
                                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                                        .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                                        .frame(maxWidth: .infinity, minHeight: 46)
                                        .background(Capsule().fill(PastelPalette.lavenderLight.swiftUIColor))
                                }
                                .accessibilityIdentifier("settings.restorePurchases")
                            }
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(.white.opacity(0.9)))

                        // Grown-up Gated Compliance & About
                        VStack(spacing: 10) {
                            Button {
                                pendingGateAction = .privacy
                            } label: {
                                HStack {
                                    Label(localization.text("settings.privacy"), systemImage: "hand.raised.fill")
                                    Spacer()
                                    Image(systemName: "lock.shield.fill")
                                }
                                .font(.system(.subheadline, design: .rounded).weight(.bold))
                                .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                                .padding(14)
                                .frame(minHeight: 48)
                                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(PastelPalette.mintLight.swiftUIColor))
                            }
                            .accessibilityIdentifier("settings.privacyButton")

                            Button {
                                pendingGateAction = .rateApp
                            } label: {
                                HStack {
                                    Label(localization.text("settings.rate_app"), systemImage: "star.bubble.fill")
                                    Spacer()
                                    Image(systemName: "lock.shield.fill")
                                }
                                .font(.system(.subheadline, design: .rounded).weight(.bold))
                                .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                                .padding(14)
                                .frame(minHeight: 48)
                                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(PastelPalette.butterWarm.swiftUIColor))
                            }
                            .accessibilityIdentifier("settings.rateButton")

                            Text(localization.text("settings.about"))
                                .font(.system(.caption, design: .rounded).weight(.medium))
                                .foregroundStyle(PastelPalette.textMuted.swiftUIColor)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(.white.opacity(0.9)))
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $pendingGateAction) { action in
            ParentalGateSheet(
                onPassed: {
                    pendingGateAction = nil
                    executeGatedAction(action)
                },
                onCancel: {
                    pendingGateAction = nil
                }
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showPrivacySheet) {
            PrivacyPolicySheet()
        }
    }

    private func executeGatedAction(_ action: GatedSettingsAction) {
        switch action {
        case .privacy:
            showPrivacySheet = true
        case .rateApp:
            requestReview()
        case .purchasePremium:
            Task {
                let ok = await purchases.purchasePremium()
                if ok {
                    container.unlockPremiumLocally()
                }
            }
        case .restorePurchases:
            Task {
                await purchases.restorePurchases()
                if purchases.isPremiumPurchased {
                    container.unlockPremiumLocally()
                }
            }
        }
    }
}

private struct PrivacyPolicySheet: View {
    @EnvironmentObject private var localization: LocalizationService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(PastelPalette.mintDark.swiftUIColor)
                        Text(localization.text("settings.privacy"))
                            .font(.system(.title3, design: .rounded).weight(.heavy))
                            .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                    }

                    Text(localization.text("privacy.body"))
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                        .lineSpacing(4)
                }
                .padding(20)
            }
            .background(PastelPalette.cloudWhite.swiftUIColor.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.text("nav.back")) { dismiss() }
                }
            }
        }
    }
}
