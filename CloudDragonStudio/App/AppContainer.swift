import CoreGraphics
import SwiftUI
import UIKit

@MainActor
final class AppContainer: ObservableObject {
    @Published var saveData: StudioSaveData
    @Published private(set) var zonePaintImages: [DragonZone: CGImage] = [:]
    @Published var catalog: [CatalogItem]
    @Published var reduceMotionPreference: Bool {
        didSet {
            UserDefaults.standard.set(reduceMotionPreference, forKey: Self.reduceMotionKey)
        }
    }

    let router = AppRouter()
    let localization = LocalizationService()
    let haptics = HapticsService()
    let audio = AudioService()
    let ads = MockAdService()
    let persistence: PersistenceService
    let purchases: PurchaseService

    private static let reduceMotionKey = "cloud_dragon_reduce_motion"

    init(persistence: PersistenceService? = nil) {
        let store = persistence ?? PersistenceService()
        self.persistence = store
        let loaded = store.load()
        self.saveData = loaded
        self.catalog = CatalogLoader.loadBundledCatalog()
        self.purchases = PurchaseService(initialPremium: loaded.isPremiumUnlocked)
        self.reduceMotionPreference = UserDefaults.standard.bool(forKey: Self.reduceMotionKey)
        rebuildPaintImages()
    }

    var character: CloudDragonCharacter {
        get { saveData.characters[saveData.activeSlotIndex] }
        set {
            saveData.characters[saveData.activeSlotIndex] = newValue
            persistState()
        }
    }

    var activeSlotIndex: Int {
        saveData.activeSlotIndex
    }

    var isPremium: Bool {
        saveData.isPremiumUnlocked || purchases.isPremiumPurchased
    }

    var isDailyWishCompletedToday: Bool {
        saveData.lastDailyWishDateKey == Self.todayDateKey()
    }

    func effectiveReduceMotion(systemReduceMotion: Bool) -> Bool {
        systemReduceMotion || reduceMotionPreference
    }

    func selectSlot(_ index: Int) {
        guard index >= 0 && index < saveData.characters.count else { return }
        saveData.activeSlotIndex = index
        rebuildPaintImages()
        persistState()
    }

    func commitPaintStroke(_ stroke: PaintStroke) {
        var current = character
        current.addStroke(stroke)
        saveData.characters[saveData.activeSlotIndex] = current
        collectSticker("sticker_scale_artist")
        rebuildPaintImages()
        persistState()
    }

    func undoPaint(zone: DragonZone) {
        var current = character
        if current.undo(zone: zone) {
            saveData.characters[saveData.activeSlotIndex] = current
            rebuildPaintImages()
            persistState()
        }
    }

    func redoPaint(zone: DragonZone) {
        var current = character
        if current.redo(zone: zone) {
            saveData.characters[saveData.activeSlotIndex] = current
            rebuildPaintImages()
            persistState()
        }
    }

    func clearPaint(zone: DragonZone) {
        var current = character
        current.clear(zone: zone)
        saveData.characters[saveData.activeSlotIndex] = current
        rebuildPaintImages()
        persistState()
    }

    func equipItem(_ item: CatalogItem, color: CodableColor?) {
        var current = character
        if current.equippedItems[item.category.rawValue] == item.id {
            current.equippedItems.removeValue(forKey: item.category.rawValue)
        } else {
            current.equippedItems[item.category.rawValue] = item.id
            let resolved = color ?? current.equippedColors[item.id] ?? item.defaultColor
            current.equippedColors[item.id] = resolved
            current.expression = .delighted
            collectSticker("sticker_wardrobe_star")
        }
        saveData.characters[saveData.activeSlotIndex] = current
        persistState()
    }

    func unequipCategory(_ category: ItemCategory) {
        var current = character
        current.equippedItems.removeValue(forKey: category.rawValue)
        saveData.characters[saveData.activeSlotIndex] = current
        persistState()
    }

    func setItemColor(_ color: CodableColor, for itemId: String) {
        var current = character
        current.equippedColors[itemId] = color
        saveData.characters[saveData.activeSlotIndex] = current
        persistState()
    }

    func setExpression(_ expression: DragonExpression) {
        var current = character
        current.expression = expression
        saveData.characters[saveData.activeSlotIndex] = current
        persistState()
    }

    func togglePose() {
        var current = character
        current.pose = (current.pose == .sitting) ? .waving : .sitting
        saveData.characters[saveData.activeSlotIndex] = current
        persistState()
    }

    func isItemUnlocked(_ item: CatalogItem) -> Bool {
        item.isFree || isPremium || saveData.unlockedRewardItemIDs.contains(item.id)
    }

    func unlockRewardItem(_ itemId: String) {
        if !saveData.unlockedRewardItemIDs.contains(itemId) {
            saveData.unlockedRewardItemIDs.append(itemId)
            persistState()
        }
    }

    func unlockPremiumLocally() {
        saveData.isPremiumUnlocked = true
        persistState()
    }

    func collectSticker(_ stickerId: String) {
        if !saveData.collectedStickerIDs.contains(stickerId) {
            saveData.collectedStickerIDs.append(stickerId)
            persistState()
        }
    }

    func completeDailyWish() {
        saveData.lastDailyWishDateKey = Self.todayDateKey()
        collectSticker("sticker_daily_wish_star")
        persistState()
    }

    func savePhoto(_ image: UIImage) -> String? {
        guard let fileName = persistence.savePhotoImage(image) else { return nil }
        saveData.savedPhotoFileNames.insert(fileName, at: 0)
        collectSticker("sticker_photographer")
        persistState()
        return fileName
    }

    func deletePhoto(named fileName: String) {
        saveData.savedPhotoFileNames.removeAll { $0 == fileName }
        persistence.deletePhoto(named: fileName)
        persistState()
    }

    func navigateToArea(_ destination: AppDestination, isPainting: Bool = false) {
        _ = ads.presentTransitionInterstitialIfAllowed(
            isPremium: isPremium,
            isPainting: isPainting,
            now: Date()
        )
        router.open(destination)
    }

    func rebuildPaintImages() {
        zonePaintImages = MaskedBrushRenderer.renderZoneImages(for: character)
    }

    private func persistState() {
        persistence.save(saveData)
    }

    static func todayDateKey() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
