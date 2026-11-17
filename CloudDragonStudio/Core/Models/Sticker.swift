import Foundation

struct StickerDefinition: Identifiable, Equatable, Sendable {
    let id: String
    let titleEn: String
    let titleVi: String
    let symbol: String
    let tint: CodableColor

    func localizedTitle(_ language: AppLanguage) -> String {
        language == .vi ? titleVi : titleEn
    }

    static let allStickers: [StickerDefinition] = [
        StickerDefinition(id: "sticker_welcome_cloud", titleEn: "First Cloud", titleVi: "Mây Đầu Tiên", symbol: "cloud.fill", tint: PastelPalette.skyBlue),
        StickerDefinition(id: "sticker_first_brush", titleEn: "First Brush", titleVi: "Nét Cọ Đầu", symbol: "paintbrush.pointed.fill", tint: PastelPalette.mintGreen),
        StickerDefinition(id: "sticker_scale_artist", titleEn: "Scale Artist", titleVi: "Nghệ Sĩ Vảy", symbol: "sparkles", tint: PastelPalette.lavenderPurple),
        StickerDefinition(id: "sticker_wardrobe_star", titleEn: "Cloud Stylist", titleVi: "Nhà Tạo Mẫu", symbol: "crown.fill", tint: PastelPalette.butterYellow),
        StickerDefinition(id: "sticker_clean_dragon", titleEn: "Fresh Dragon", titleVi: "Rồng Sạch Mát", symbol: "bubbles.and.sparkles.fill", tint: PastelPalette.skyBlue),
        StickerDefinition(id: "sticker_baker_star", titleEn: "Star Baker", titleVi: "Bếp Trưởng Sao", symbol: "birthday.cake.fill", tint: PastelPalette.peachSoft),
        StickerDefinition(id: "sticker_pet_care", titleEn: "Pet Lover", titleVi: "Yêu Động Vật", symbol: "pawprint.fill", tint: PastelPalette.roseSoft),
        StickerDefinition(id: "sticker_photographer", titleEn: "Photographer", titleVi: "Nhiếp Ảnh Gia", symbol: "camera.fill", tint: PastelPalette.butterDark),
        StickerDefinition(id: "sticker_daily_wish_star", titleEn: "Wish Star", titleVi: "Ngôi Sao Ước", symbol: "moon.stars.fill", tint: PastelPalette.lavenderDark)
    ]
}

struct StudioSaveData: Codable, Equatable, Sendable {
    static let maxSlots = 12

    var activeSlotIndex: Int
    var characters: [CloudDragonCharacter]
    var isPremiumUnlocked: Bool
    var unlockedRewardItemIDs: [String]
    var collectedStickerIDs: [String]
    var savedPhotoFileNames: [String]
    var lastDailyWishDateKey: String?

    static func makeDefault() -> StudioSaveData {
        let slots = (0..<maxSlots).map { CloudDragonCharacter.createPreset(slotIndex: $0) }
        return StudioSaveData(
            activeSlotIndex: 0,
            characters: slots,
            isPremiumUnlocked: false,
            unlockedRewardItemIDs: [],
            collectedStickerIDs: ["sticker_welcome_cloud", "sticker_first_brush"],
            savedPhotoFileNames: [],
            lastDailyWishDateKey: nil
        )
    }
}
