import Photos
import SwiftUI
import UIKit

private struct PlacedPhotoSticker: Identifiable {
    let id = UUID()
    var normalizedPoint: CGPoint
    var label: String
}

private struct BackdropPreset: Identifiable {
    let id: Int
    let titleKey: String
    let colors: [CodableColor]
    let symbol: String
}

struct PhotoBoothView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var localization: LocalizationService
    @EnvironmentObject private var haptics: HapticsService
    @EnvironmentObject private var audio: AudioService
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    @State private var selectedBackdrop = 0
    @State private var showFlash = false
    @State private var placedStickers: [PlacedPhotoSticker] = []
    @State private var showAlbumSheet = false
    @State private var statusBanner: String?

    private let backdrops: [BackdropPreset] = [
        BackdropPreset(id: 0, titleKey: "photo.bg.sunrise", colors: [CodableColor(hex: 0xFF7E67), CodableColor(hex: 0xFFD166), CodableColor(hex: 0xFFEAA7)], symbol: "sunrise.fill"),
        BackdropPreset(id: 1, titleKey: "photo.bg.starry", colors: [CodableColor(hex: 0x1E272C), CodableColor(hex: 0x34495E), CodableColor(hex: 0x5F27CD)], symbol: "moon.stars.fill"),
        BackdropPreset(id: 2, titleKey: "photo.bg.garden", colors: [CodableColor(hex: 0x1DD1A1), CodableColor(hex: 0x48DBFB), CodableColor(hex: 0xFF9FF3)], symbol: "camera.macro"),
        BackdropPreset(id: 3, titleKey: "photo.bg.castle", colors: [CodableColor(hex: 0xFF6B81), CodableColor(hex: 0xFFA502), CodableColor(hex: 0xFFE66D)], symbol: "sparkles")
    ]

    private var reduceMotion: Bool {
        container.effectiveReduceMotion(systemReduceMotion: systemReduceMotion)
    }

    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height

            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.929, green: 0.906, blue: 0.965),
                        Color(red: 0.878, green: 0.949, blue: 0.996),
                        Color(red: 1.0, green: 0.953, blue: 0.878)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 8) {
                    TopNavBar(
                        title: localization.text("area.photo"),
                        subtitle: localization.text("area.photo.desc"),
                        backLabel: localization.text("nav.home"),
                        onBack: { router.popToHome() },
                        trailingContent: AnyView(albumButton)
                    )

                    backdropAndPoseRow

                    if isLandscape {
                        HStack(spacing: 16) {
                            photoStage
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            actionButtonsColumn
                                .frame(width: min(260, geo.size.width * 0.30))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    } else {
                        photoStage
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, 16)
                        actionButtonsRow
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
                }

                if let statusBanner {
                    VStack {
                        Spacer()
                        Text(statusBanner)
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(PastelPalette.lavenderDark.swiftUIColor))
                            .padding(.bottom, 84)
                    }
                    .transition(.opacity)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showAlbumSheet) {
            PhotoAlbumSheet(onExportToPhotos: { image in
                exportToApplePhotos(image)
            })
        }
    }

    private var albumButton: some View {
        Button {
            audio.playSparkle()
            showAlbumSheet = true
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 16, weight: .bold))
                Text("\(container.saveData.savedPhotoFileNames.count)")
                    .font(.system(.subheadline, design: .rounded).weight(.heavy))
            }
            .foregroundStyle(PastelPalette.textDark.swiftUIColor)
            .padding(.horizontal, 12)
            .frame(minWidth: 52, minHeight: 46)
            .background(
                Capsule()
                    .fill(PastelPalette.butterYellow.swiftUIColor)
                    .overlay(Capsule().stroke(.white, lineWidth: 2))
            )
        }
        .accessibilityIdentifier("photo.albumButton")
    }

    private var backdropAndPoseRow: some View {
        HStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(backdrops) { bg in
                        let isSelected = selectedBackdrop == bg.id
                        Button {
                            selectedBackdrop = bg.id
                            audio.playPop()
                        } label: {
                            Image(systemName: bg.symbol)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 48, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(LinearGradient(colors: bg.colors.map(\.swiftUIColor), startPoint: .top, endPoint: .bottom))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .stroke(isSelected ? PastelPalette.textDark.swiftUIColor : .white, lineWidth: isSelected ? 3 : 1.5)
                                        )
                                )
                        }
                        .accessibilityIdentifier("photo.bg.\(bg.id)")
                    }
                }
            }

            Button {
                container.togglePose()
                audio.playPop()
            } label: {
                Label(
                    container.character.pose == .sitting ? localization.text("photo.pose.sit") : localization.text("photo.pose.wave"),
                    systemImage: container.character.pose == .sitting ? "figure.seated.side" : "hand.wave.fill"
                )
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                .padding(.horizontal, 12)
                .frame(minHeight: 44)
                .background(Capsule().fill(PastelPalette.lavenderPurple.swiftUIColor))
            }
            .accessibilityIdentifier("photo.poseToggle")
        }
        .padding(.horizontal, 14)
    }

    private var photoStage: some View {
        GeometryReader { stageGeo in
            let side = min(stageGeo.size.width, stageGeo.size.height)
            let bgColors = backdrops[selectedBackdrop].colors.map(\.swiftUIColor)

            ZStack {
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(LinearGradient(colors: bgColors, startPoint: .top, endPoint: .bottom))
                    .overlay(RoundedRectangle(cornerRadius: 36, style: .continuous).stroke(.white, lineWidth: 5))
                    .shadow(color: Color.black.opacity(0.16), radius: 16, y: 6)

                DragonView(
                    character: container.character,
                    reduceMotion: reduceMotion,
                    catalog: container.catalog,
                    zonePaintImages: container.zonePaintImages
                )
                .frame(width: side * 0.90, height: side * 0.90)

                ForEach(placedStickers) { st in
                    Text(st.label)
                        .font(.system(.caption, design: .rounded).weight(.bold))
                        .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.white.opacity(0.95))
                                .overlay(Capsule().stroke(PastelPalette.cardBorder.swiftUIColor, lineWidth: 1.5))
                        )
                        .position(x: st.normalizedPoint.x * side, y: st.normalizedPoint.y * side)
                        .onTapGesture {
                            placedStickers.removeAll { $0.id == st.id }
                            audio.playPop()
                        }
                }

                if showFlash {
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(.white.opacity(0.88))
                }
            }
            .frame(width: side, height: side)
            .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        let nx = min(max(value.location.x / max(side, 1), 0.14), 0.86)
                        let ny = min(max(value.location.y / max(side, 1), 0.12), 0.88)
                        let pool = localization.language == .vi
                            ? ["Lấp lánh", "Yêu thương", "Ngon tuyệt", "Công chúa", "Mây bay", "Ngôi sao"]
                            : ["Sparkle", "Love", "Sweet", "Royal", "Cloud", "Star"]
                        let label = pool[placedStickers.count % pool.count]
                        placedStickers.append(PlacedPhotoSticker(normalizedPoint: CGPoint(x: nx, y: ny), label: label))
                        audio.playSparkle()
                    }
            )
            .accessibilityIdentifier("photo.stage")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var actionButtonsRow: some View {
        HStack(spacing: 10) {
            snapButton
            clearStickersButton
        }
    }

    private var actionButtonsColumn: some View {
        VStack(spacing: 12) {
            snapButton
            clearStickersButton
        }
    }

    private var snapButton: some View {
        Button {
            snapAndSavePhoto()
        } label: {
            Label(localization.text("photo.snap"), systemImage: "camera.fill")
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(Capsule().fill(PastelPalette.butterYellow.swiftUIColor))
        }
        .accessibilityIdentifier("photo.snapButton")
    }

    private var clearStickersButton: some View {
        Button {
            placedStickers.removeAll()
            audio.playPop()
        } label: {
            Label(localization.text("photo.clear_stickers"), systemImage: "sparkles.rectangle.stack")
                .font(.system(.subheadline, design: .rounded).weight(.bold))
                .foregroundStyle(PastelPalette.textMuted.swiftUIColor)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(Capsule().fill(.white.opacity(0.95)))
        }
        .accessibilityIdentifier("photo.clearStickers")
    }

    private func snapAndSavePhoto() {
        haptics.sparkle(reduceMotion: reduceMotion)
        audio.playCheer()

        let rendered = renderSnapshotImage(size: CGSize(width: 900, height: 900))
        _ = container.savePhoto(rendered)

        showFlash = true
        statusBanner = localization.text("photo.saved_toast")
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 250_000_000)
            showFlash = false
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            statusBanner = nil
        }
    }

    private func renderSnapshotImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { uiCtx in
            let ctx = uiCtx.cgContext
            let rect = CGRect(origin: .zero, size: size)
            let bgColors = backdrops[selectedBackdrop].colors.map { $0.uiColor.cgColor } as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: bgColors, locations: [0.0, 0.5, 1.0]) {
                ctx.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size.height), options: [])
            }

            let dragonRect = rect.insetBy(dx: size.width * 0.05, dy: size.height * 0.05)
            CoreGraphicsDragonDrawer.drawDragon(
                in: ctx,
                rect: dragonRect,
                character: container.character,
                catalog: container.catalog,
                zonePaintImages: container.zonePaintImages
            )

            for st in placedStickers {
                let pt = CGPoint(x: st.normalizedPoint.x * size.width, y: st.normalizedPoint.y * size.height)
                let pillRect = CGRect(x: pt.x - 68, y: pt.y - 24, width: 136, height: 48)
                let path = UIBezierPath(roundedRect: pillRect, cornerRadius: 24)
                UIColor.white.withAlphaComponent(0.94).setFill()
                path.fill()
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 22),
                    .foregroundColor: PastelPalette.textDark.uiColor
                ]
                let textSize = (st.label as NSString).size(withAttributes: attrs)
                let textRect = CGRect(x: pt.x - textSize.width * 0.5, y: pt.y - textSize.height * 0.5, width: textSize.width, height: textSize.height)
                (st.label as NSString).draw(in: textRect, withAttributes: attrs)
            }
        }
    }

    private func exportToApplePhotos(_ image: UIImage) {
        Task { @MainActor in
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            guard status == .authorized || status == .limited else {
                statusBanner = localization.text("photo.export_denied")
                return
            }
            do {
                try await PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }
                statusBanner = localization.text("photo.exported_toast")
            } catch {
                statusBanner = localization.text("photo.export_denied")
            }
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            statusBanner = nil
        }
    }
}

private struct PhotoAlbumSheet: View {
    let onExportToPhotos: (UIImage) -> Void

    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var localization: LocalizationService
    @EnvironmentObject private var audio: AudioService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                let photos = container.saveData.savedPhotoFileNames
                if photos.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(PastelPalette.lavenderDark.swiftUIColor)
                        Text(localization.text("photo.album_empty"))
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundStyle(PastelPalette.textMuted.swiftUIColor)
                            .multilineTextAlignment(.center)
                    }
                    .padding(36)
                    .frame(maxWidth: .infinity)
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 14)], spacing: 14) {
                        ForEach(photos, id: \.self) { fileName in
                            if let uiImage = container.persistence.loadPhotoImage(named: fileName) {
                                VStack(spacing: 8) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                                    HStack(spacing: 10) {
                                        Button {
                                            onExportToPhotos(uiImage)
                                        } label: {
                                            Image(systemName: "square.and.arrow.down")
                                                .frame(minWidth: 44, minHeight: 36)
                                                .background(Capsule().fill(PastelPalette.mintLight.swiftUIColor))
                                        }
                                        .accessibilityLabel(localization.text("photo.export"))

                                        Spacer()

                                        Button(role: .destructive) {
                                            audio.playPop()
                                            container.deletePhoto(named: fileName)
                                        } label: {
                                            Image(systemName: "trash")
                                                .frame(minWidth: 44, minHeight: 36)
                                                .background(Capsule().fill(PastelPalette.roseLight.swiftUIColor))
                                        }
                                    }
                                    .foregroundStyle(PastelPalette.textDark.swiftUIColor)
                                }
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(.white)
                                        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(PastelPalette.butterYellow.swiftUIColor, lineWidth: 2.5))
                                )
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .background(PastelPalette.roomStudioBg.swiftUIColor.ignoresSafeArea())
            .navigationTitle(localization.text("photo.album_title"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.text("nav.back")) { dismiss() }
                }
            }
        }
    }
}
