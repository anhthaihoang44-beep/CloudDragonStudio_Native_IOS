import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable, Codable, Sendable {
    case en
    case vi

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .en: return "English"
        case .vi: return "Tiếng Việt"
        }
    }
}

@MainActor
final class LocalizationService: ObservableObject {
    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: Self.storageKey)
        }
    }

    private static let storageKey = "cloud_dragon_app_language"

    init() {
        if let saved = UserDefaults.standard.string(forKey: Self.storageKey),
           let parsed = AppLanguage(rawValue: saved) {
            self.language = parsed
        } else {
            let preferred = Locale.preferredLanguages.first ?? "en"
            self.language = preferred.hasPrefix("vi") ? .vi : .en
        }
    }

    func text(_ key: String) -> String {
        if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            let localized = bundle.localizedString(forKey: key, value: nil, table: "Localizable")
            if localized != key {
                return localized
            }
        }
        let fallback = NSLocalizedString(key, tableName: "Localizable", bundle: .main, value: key, comment: "")
        return fallback
    }
}
