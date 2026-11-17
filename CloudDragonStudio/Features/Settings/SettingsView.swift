import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var localization: LocalizationService
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    private var reduceMotion: Bool {
        container.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    var body: some View {
        ZStack {
            CloudBackdropView(reduceMotion: reduceMotion)

            VStack(spacing: 16) {
                TopNavBar(
                    title: localization.text("mode.settings"),
                    backLabel: localization.text("nav.home"),
                    onBack: { router.popToHome() }
                )

                ScrollView {
                    VStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(localization.text("settings.language"))
                                .font(.system(.headline, design: .rounded).weight(.bold))
                                .foregroundStyle(PastelPalette.inkText.swiftUIColor)

                            HStack(spacing: 10) {
                                ForEach(AppLanguage.allCases) { lang in
                                    Button {
                                        localization.language = lang
                                    } label: {
                                        Text(lang.displayName)
                                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                                            .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                                            .frame(maxWidth: .infinity, minHeight: 46)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                    .fill(
                                                        localization.language == lang
                                                            ? PastelPalette.mint.swiftUIColor
                                                            : Color.white.opacity(0.85)
                                                    )
                                            )
                                    }
                                    .accessibilityIdentifier("settings.lang.\(lang.rawValue)")
                                }
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(.white.opacity(0.82))
                        )

                        Toggle(isOn: $container.reduceMotionPreference) {
                            Text(localization.text("settings.reduce_motion"))
                                .font(.system(.headline, design: .rounded).weight(.bold))
                                .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                        }
                        .tint(PastelPalette.mintDeep.swiftUIColor)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(.white.opacity(0.82))
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
