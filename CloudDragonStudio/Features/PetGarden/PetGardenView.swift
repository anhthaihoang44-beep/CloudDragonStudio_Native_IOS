import SwiftUI

enum PetActivity: String, CaseIterable, Identifiable {
    case petting
    case feeding
    case brushing
    case playing

    var id: String { rawValue }
}

private struct FloatingHeart: Identifiable {
    let id = UUID()
    let normalizedPoint: CGPoint
}

struct PetGardenView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var localization: LocalizationService
    @EnvironmentObject private var haptics: HapticsService
    @EnvironmentObject private var audio: AudioService
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    @State private var selectedPet: CloudPetType = .rabbit
    @State private var currentActivity: PetActivity = .petting
    @State private var happiness = 3
    @State private var floatingHearts: [FloatingHeart] = []
    @State private var petBounce = false

    private var reduceMotion: Bool {
        container.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height

            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.729, green: 0.902, blue: 0.992), // #BAE6FD
                        Color(red: 0.820, green: 0.980, blue: 0.898), // #D1FAE5
                        Color(red: 0.996, green: 0.941, blue: 0.541)  // #FEF08A
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 8) {
                    TopNavBar(
                        title: localization.text("area.pets"),
                        subtitle: localization.text("area.pets.desc"),
                        backLabel: localization.text("nav.home"),
                        onBack: { router.popToHome() }
                    )

                    petSelectorRow

                    if isLandscape {
                        HStack(spacing: 16) {
                            gardenStage
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            activityButtonsColumn
                                .frame(width: min(260, geo.size.width * 0.30))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    } else {
                        gardenStage
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, 16)
                        activityButtonsRow
                            .padding(.bottom, 16)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var petSelectorRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CloudPetType.allCases) { pet in
                    let isSelected = selectedPet == pet
                    Button {
                        haptics.tap(reduceMotion: reduceMotion)
                        audio.playPop()
                        selectedPet = pet
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: petSymbol(for: pet))
                            Text(localization.text("pet.type.\(pet.rawValue)"))
                                .font(.system(.subheadline, design: .rounded).weight(isSelected ? .heavy : .semibold))
                        }
                        .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                        .padding(.horizontal, 16)
                        .frame(minHeight: 44)
                        .background(
                            Capsule()
                                .fill(isSelected ? petTint(for: pet) : .white.opacity(0.92))
                                .overlay(Capsule().stroke(isSelected ? PastelPalette.textDark.swiftUIColor : PastelPalette.cardBorder.swiftUIColor, lineWidth: isSelected ? 2.5 : 1.5))
                        )
                    }
                    .accessibilityIdentifier("pet.tab.\(pet.rawValue)")
                }
            }
            .padding(.horizontal, 14)
        }
    }

    private var gardenStage: some View {
        GeometryReader { stageGeo in
            let side = min(stageGeo.size.width, stageGeo.size.height)
            ZStack {
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.878, green: 0.949, blue: 0.996),
                                Color(red: 0.863, green: 0.988, blue: 0.906),
                                Color(red: 0.733, green: 0.969, blue: 0.816)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 36, style: .continuous)
                            .stroke(PastelPalette.mintGreen.swiftUIColor, lineWidth: 4.5)
                    )
                    .shadow(color: PastelPalette.mintDark.swiftUIColor.opacity(0.24), radius: 16, y: 6)

                VStack {
                    HStack {
                        Image(systemName: "rainbow")
                            .foregroundStyle(PastelPalette.roseSoft.swiftUIColor)
                        Spacer()
                        Image(systemName: "sun.max.fill")
                            .foregroundStyle(PastelPalette.butterDark.swiftUIColor)
                    }
                    .font(.system(size: 26, weight: .bold))
                    .padding(.horizontal, 24)
                    .padding(.top, 18)

                    Spacer()

                    HStack(spacing: 22) {
                        Image(systemName: "camera.macro")
                        Image(systemName: "leaf.fill")
                        Image(systemName: "camera.macro")
                        Image(systemName: "leaf.fill")
                    }
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(PastelPalette.mintDark.swiftUIColor.opacity(0.65))
                    .padding(.bottom, 16)
                }

                VStack(spacing: 12) {
                    PetCanvasView(petType: selectedPet)
                        .frame(width: side * 0.44, height: side * 0.42)
                        .scaleEffect(petBounce && !reduceMotion ? 1.14 : 1.0)
                        .animation(reduceMotion ? nil : .spring(response: 0.25), value: petBounce)

                    HStack(spacing: 6) {
                        ForEach(0..<5, id: \.self) { idx in
                            Image(systemName: "heart.fill")
                                .font(.system(size: 26))
                                .foregroundStyle(idx < happiness ? Color(red: 1.0, green: 0.278, blue: 0.341) : .white.opacity(0.75))
                        }
                    }
                }

                ForEach(floatingHearts) { heart in
                    Image(systemName: "heart.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Color(red: 1.0, green: 0.278, blue: 0.341))
                        .position(x: heart.normalizedPoint.x * side, y: heart.normalizedPoint.y * side)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: side, height: side)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        let nx = min(max(value.location.x / max(side, 1), 0.1), 0.9)
                        let ny = min(max(value.location.y / max(side, 1), 0.1), 0.9)
                        triggerHeart(at: CGPoint(x: nx, y: ny))
                    }
            )
            .accessibilityIdentifier("pet.stage")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var activityButtonsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PetActivity.allCases) { act in
                    activityButton(for: act)
                }
            }
            .padding(.horizontal, 14)
        }
    }

    private var activityButtonsColumn: some View {
        VStack(spacing: 10) {
            ForEach(PetActivity.allCases) { act in
                activityButton(for: act)
            }
        }
    }

    private func activityButton(for act: PetActivity) -> some View {
        let isSelected = currentActivity == act
        return Button {
            haptics.tap(reduceMotion: reduceMotion)
            audio.playSparkle()
            currentActivity = act
            happiness = min(5, happiness + 1)
            triggerHeart(at: CGPoint(x: CGFloat.random(in: 0.35...0.65), y: CGFloat.random(in: 0.3...0.55)))
            container.collectSticker("sticker_pet_care")
        } label: {
            Label(localization.text("pet.act.\(act.rawValue)"), systemImage: activitySymbol(for: act))
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity, minHeight: 46)
                .background(
                    Capsule()
                        .fill(isSelected ? activityTint(for: act) : .white.opacity(0.95))
                        .overlay(Capsule().stroke(.white, lineWidth: 2))
                )
        }
        .accessibilityIdentifier("pet.act.\(act.rawValue)")
    }

    private func triggerHeart(at point: CGPoint) {
        let heart = FloatingHeart(normalizedPoint: point)
        floatingHearts.append(heart)
        happiness = min(5, happiness + 1)
        petBounce = true
        audio.playPop()
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 160_000_000)
            petBounce = false
            try? await Task.sleep(nanoseconds: 640_000_000)
            floatingHearts.removeAll { $0.id == heart.id }
        }
    }

    private func petSymbol(for pet: CloudPetType) -> String {
        switch pet {
        case .rabbit: return "hare.fill"
        case .fox: return "pawprint.fill"
        case .kitten: return "cat.fill"
        }
    }

    private func petTint(for pet: CloudPetType) -> Color {
        switch pet {
        case .rabbit: return PastelPalette.mintGreen.swiftUIColor
        case .fox: return PastelPalette.peachSoft.swiftUIColor
        case .kitten: return PastelPalette.butterYellow.swiftUIColor
        }
    }

    private func activitySymbol(for act: PetActivity) -> String {
        switch act {
        case .petting: return "heart.fill"
        case .feeding: return "carrot.fill"
        case .brushing: return "comb.fill"
        case .playing: return "soccerball"
        }
    }

    private func activityTint(for act: PetActivity) -> Color {
        switch act {
        case .petting: return PastelPalette.roseSoft.swiftUIColor
        case .feeding: return PastelPalette.butterYellow.swiftUIColor
        case .brushing: return PastelPalette.lavenderPurple.swiftUIColor
        case .playing: return PastelPalette.mintGreen.swiftUIColor
        }
    }
}
