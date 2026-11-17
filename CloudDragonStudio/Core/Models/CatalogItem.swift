import Foundation

enum ItemCategory: String, CaseIterable, Codable, Identifiable, Sendable {
    case hat
    case robe
    case scarf
    case glasses
    case wingsDeco

    var id: String { rawValue }

    var localizationKey: String {
        switch self {
        case .hat: return "wardrobe.cat.hat"
        case .robe: return "wardrobe.cat.robe"
        case .scarf: return "wardrobe.cat.scarf"
        case .glasses: return "wardrobe.cat.glasses"
        case .wingsDeco: return "wardrobe.cat.wingsDeco"
        }
    }
}

struct CatalogItem: Codable, Equatable, Identifiable, Sendable {
    let id: String
    let category: ItemCategory
    let nameEn: String
    let nameVi: String
    let defaultColor: CodableColor
    let isFree: Bool
    let previewSymbol: String

    func localizedName(for language: AppLanguage) -> String {
        language == .vi ? nameVi : nameEn
    }
}

enum CatalogLoader {
    static func loadBundledCatalog(bundle: Bundle = .main) -> [CatalogItem] {
        if let url = bundle.url(forResource: "catalog", withExtension: "json")
            ?? bundle.url(forResource: "catalog", withExtension: "json", subdirectory: "Catalog"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode([CatalogItem].self, from: data),
           !decoded.isEmpty {
            return decoded
        }
        return fallbackCatalog
    }

    static let fallbackCatalog: [CatalogItem] = [
        CatalogItem(id: "hat_star_crown", category: .hat, nameEn: "Star Crown", nameVi: "Vương Miện Sao", defaultColor: PastelPalette.butterYellow, isFree: true, previewSymbol: "crown"),
        CatalogItem(id: "hat_cloud_beret", category: .hat, nameEn: "Cloud Beret", nameVi: "Mũ Mây Bồng", defaultColor: PastelPalette.skyBlue, isFree: true, previewSymbol: "cloud"),
        CatalogItem(id: "hat_flower_wreath", category: .hat, nameEn: "Flower Wreath", nameVi: "Vòng Hoa Chuông", defaultColor: PastelPalette.roseSoft, isFree: true, previewSymbol: "flower"),
        CatalogItem(id: "hat_nightcap", category: .hat, nameEn: "Crescent Cap", nameVi: "Mũ Ngủ Trăng", defaultColor: PastelPalette.lavenderPurple, isFree: true, previewSymbol: "moon"),
        CatalogItem(id: "hat_dragon_tiara", category: .hat, nameEn: "Dragon Tiara", nameVi: "Vương Miện Rồng", defaultColor: PastelPalette.mintGreen, isFree: false, previewSymbol: "tiara"),

        CatalogItem(id: "robe_cloud_cape", category: .robe, nameEn: "Cloud Cape", nameVi: "Áo Choàng Mây", defaultColor: PastelPalette.skyBlue, isFree: true, previewSymbol: "cape"),
        CatalogItem(id: "robe_pastel_dress", category: .robe, nameEn: "Fluffy Dress", nameVi: "Váy Bồng Xòe", defaultColor: PastelPalette.roseSoft, isFree: true, previewSymbol: "dress"),
        CatalogItem(id: "robe_starry_vest", category: .robe, nameEn: "Starry Vest", nameVi: "Áo Gi-lê Sao", defaultColor: PastelPalette.butterYellow, isFree: true, previewSymbol: "vest"),
        CatalogItem(id: "robe_night_gown", category: .robe, nameEn: "Moonlit Gown", nameVi: "Áo Lụa Đêm Sao", defaultColor: PastelPalette.lavenderPurple, isFree: false, previewSymbol: "gown"),

        CatalogItem(id: "scarf_ribbon", category: .scarf, nameEn: "Silk Ribbon Bow", nameVi: "Nơ Lụa Mềm", defaultColor: PastelPalette.peachSoft, isFree: true, previewSymbol: "bow"),
        CatalogItem(id: "scarf_cloud_boa", category: .scarf, nameEn: "Warm Cloud Scarf", nameVi: "Khăn Choàng Ấm", defaultColor: PastelPalette.skyLight, isFree: true, previewSymbol: "scarf"),
        CatalogItem(id: "scarf_bell_choker", category: .scarf, nameEn: "Windchime Bell", nameVi: "Chuông Gió Nhỏ", defaultColor: PastelPalette.butterYellow, isFree: true, previewSymbol: "bell"),
        CatalogItem(id: "scarf_pearl_necklace", category: .scarf, nameEn: "Cloud Pearls", nameVi: "Vòng Ngọc Mây", defaultColor: PastelPalette.mintGreen, isFree: true, previewSymbol: "pearls"),

        CatalogItem(id: "glasses_star", category: .glasses, nameEn: "Star Glasses", nameVi: "Kính Ngôi Sao", defaultColor: PastelPalette.butterYellow, isFree: true, previewSymbol: "star_glasses"),
        CatalogItem(id: "glasses_heart", category: .glasses, nameEn: "Heart Shades", nameVi: "Kính Trái Tim", defaultColor: PastelPalette.roseSoft, isFree: true, previewSymbol: "heart_glasses"),
        CatalogItem(id: "glasses_cloud_mask", category: .glasses, nameEn: "Masquerade Mask", nameVi: "Mặt Nạ Vũ Hội", defaultColor: PastelPalette.lavenderPurple, isFree: false, previewSymbol: "mask"),

        CatalogItem(id: "wings_sparkle", category: .wingsDeco, nameEn: "Fairy Wings", nameVi: "Cánh Bướm Tiên", defaultColor: PastelPalette.mintGreen, isFree: true, previewSymbol: "fairy_wings"),
        CatalogItem(id: "wings_feather", category: .wingsDeco, nameEn: "Feather Wings", nameVi: "Cánh Lông Vũ", defaultColor: PastelPalette.lavenderPurple, isFree: true, previewSymbol: "feather_wings"),
        CatalogItem(id: "wings_rainbow_bow", category: .wingsDeco, nameEn: "Sky Ribbon", nameVi: "Nơ Lưng Cầu Vồng", defaultColor: PastelPalette.peachSoft, isFree: true, previewSymbol: "back_bow"),
        CatalogItem(id: "wings_halo", category: .wingsDeco, nameEn: "Star Halo", nameVi: "Vòng Hào Quang", defaultColor: PastelPalette.butterYellow, isFree: false, previewSymbol: "halo")
    ]
}
