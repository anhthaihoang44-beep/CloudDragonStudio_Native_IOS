import SwiftUI

struct DailyWishView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var localization: LocalizationService
    @EnvironmentObject private var audio: AudioService
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    private var reduceMotion: Bool {
        container.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    private var todayWishText: String {
        let dayIndex = Calendar.current.component(.day, from: Date()) % 7
        return localization.text("wish.msg.\(dayIndex)")
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    PastelPalette.roomBakeBg.swiftUIColor,
                    PastelPalette.skyTop.swiftUIColor
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                TopNavBar(
                    title: localization.text("mode.daily_wish"),
                    backLabel: localization.text("nav.home"),
                    onBack: { router.popToHome() }
                )

                Spacer()

                VStack(spacing: 16) {
                    DragonView(
                        character: container.character,
                        reduceMotion: reduceMotion,
                        catalog: container.catalog,
                        zonePaintImages: container.zonePaintImages
                    )
                    .frame(width: 190, height: 190)

                    Text(todayWishText)
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                        .multilineTextAlignment(.center)
                        .padding(18)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(.white.opacity(0.95))
                                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(PastelPalette.butterYellow.swiftUIColor, lineWidth: 2.5))
                        )

                    Text(localization.text("wish.no_grading_note"))
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(PastelPalette.textMuted.swiftUIColor)
                        .multilineTextAlignment(.center)

                    Button {
                        container.completeDailyWish()
                        container.setExpression(.delighted)
                        audio.playCheer()
                        router.popToHome()
                    } label: {
                        Label(
                            container.isDailyWishCompletedToday ? localization.text("wish.done_btn") : localization.text("wish.accept_btn"),
                            systemImage: "sparkles"
                        )
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                        .padding(.horizontal, 28)
                        .frame(minHeight: 52)
                        .background(Capsule().fill(PastelPalette.mintGreen.swiftUIColor))
                    }
                    .accessibilityIdentifier("wish.acceptButton")
                }
                .padding(22)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.white.opacity(0.75))
                )
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
