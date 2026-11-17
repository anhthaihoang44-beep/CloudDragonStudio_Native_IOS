import SwiftUI

struct ParentalGateSheet: View {
    let onPassed: () -> Void
    let onCancel: () -> Void

    @EnvironmentObject private var localization: LocalizationService
    @EnvironmentObject private var audio: AudioService

    @State private var challenge = ParentalGateChallenge.generate()
    @State private var answerText = ""
    @State private var errorText: String?
    @State private var holdProgress: Double = 0.0
    @State private var isHolding = false
    @State private var holdTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(PastelPalette.lavenderDark.swiftUIColor)
                Text(localization.text("gate.title"))
                    .font(.system(.title3, design: .rounded).weight(.heavy))
                    .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                Spacer()
                Button(action: {
                    stopHold()
                    onCancel()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(PastelPalette.mutedText.swiftUIColor)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel(localization.text("nav.back"))
            }

            Text(localization.text("gate.prompt"))
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundStyle(PastelPalette.mutedText.swiftUIColor)
                .multilineTextAlignment(.center)

            Text(challenge.equationText)
                .font(.system(.title, design: .rounded).weight(.heavy))
                .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(PastelPalette.lavenderLight.swiftUIColor)
                )

            HStack(spacing: 10) {
                TextField("?", text: $answerText)
                    .keyboardType(.numberPad)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .multilineTextAlignment(.center)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(PastelPalette.cardBorder.swiftUIColor, lineWidth: 2)
                            )
                    )
                    .accessibilityIdentifier("gate.answerField")

                Button {
                    checkMathAnswer()
                } label: {
                    Text(localization.text("gate.verify"))
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                        .padding(.horizontal, 18)
                        .frame(minHeight: 48)
                        .background(
                            Capsule().fill(PastelPalette.mintGreen.swiftUIColor)
                        )
                }
                .accessibilityIdentifier("gate.verifyButton")
            }

            if let errorText {
                Text(errorText)
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(PastelPalette.roseDark.swiftUIColor)
            }

            Divider()

            // Alternative 3-second press-and-hold option
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(PastelPalette.skyLight.swiftUIColor)
                        Capsule()
                            .fill(PastelPalette.butterYellow.swiftUIColor)
                            .frame(width: geo.size.width * holdProgress)
                    }
                }
                .frame(height: 12)

                Label(localization.text("gate.hold"), systemImage: "hand.tap.fill")
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(PastelPalette.inkText.swiftUIColor)
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(isHolding ? PastelPalette.butterYellow.swiftUIColor : PastelPalette.skyLight.swiftUIColor)
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !isHolding {
                                    startHold()
                                }
                            }
                            .onEnded { _ in
                                stopHold()
                            }
                    )
                    .accessibilityIdentifier("gate.holdButton")
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(PastelPalette.cloudWhite.swiftUIColor)
        )
        .onDisappear {
            stopHold()
        }
    }

    private func checkMathAnswer() {
        let trimmed = answerText.trimmingCharacters(in: .whitespacesAndNewlines)
        if let val = Int(trimmed), val == challenge.expectedAnswer {
            audio.playSparkle()
            onPassed()
        } else {
            audio.playPop()
            errorText = localization.text("gate.wrong")
            challenge = ParentalGateChallenge.generate()
            answerText = ""
        }
    }

    private func startHold() {
        isHolding = true
        holdProgress = 0.0
        holdTask?.cancel()
        holdTask = Task { @MainActor in
            let steps = 30
            for step in 1...steps {
                try? await Task.sleep(nanoseconds: 100_000_000)
                if Task.isCancelled || !isHolding { return }
                holdProgress = Double(step) / Double(steps)
            }
            if isHolding {
                audio.playSparkle()
                isHolding = false
                onPassed()
            }
        }
    }

    private func stopHold() {
        isHolding = false
        holdTask?.cancel()
        holdTask = nil
        holdProgress = 0.0
    }
}
