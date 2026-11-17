import Foundation
import UIKit

@MainActor
final class PersistenceService {
    private let fileManager: FileManager
    private let baseDirectory: URL

    init(fileManager: FileManager = .default, customDirectory: URL? = nil) {
        self.fileManager = fileManager
        if let customDirectory {
            self.baseDirectory = customDirectory
        } else {
            let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
                ?? fileManager.temporaryDirectory
            self.baseDirectory = docs.appendingPathComponent("CloudDragonStudioData", isDirectory: true)
        }
        ensureDirectories()
    }

    private var saveFileURL: URL {
        baseDirectory.appendingPathComponent("cloud_dragon_save_v1.json")
    }

    var photosDirectoryURL: URL {
        baseDirectory.appendingPathComponent("photos", isDirectory: true)
    }

    private func ensureDirectories() {
        try? fileManager.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: photosDirectoryURL, withIntermediateDirectories: true)
    }

    func load() -> StudioSaveData {
        guard fileManager.fileExists(atPath: saveFileURL.path),
              let data = try? Data(contentsOf: saveFileURL),
              var decoded = try? JSONDecoder().decode(StudioSaveData.self, from: data) else {
            return .makeDefault()
        }

        // Guarantee exactly 12 character slots
        if decoded.characters.count < StudioSaveData.maxSlots {
            for idx in decoded.characters.count..<StudioSaveData.maxSlots {
                decoded.characters.append(CloudDragonCharacter.createPreset(slotIndex: idx))
            }
        } else if decoded.characters.count > StudioSaveData.maxSlots {
            decoded.characters = Array(decoded.characters.prefix(StudioSaveData.maxSlots))
        }
        decoded.activeSlotIndex = min(max(decoded.activeSlotIndex, 0), StudioSaveData.maxSlots - 1)
        decoded.savedPhotoFileNames = decoded.savedPhotoFileNames.filter {
            fileManager.fileExists(atPath: photoURL(for: $0).path)
        }
        return decoded
    }

    func save(_ state: StudioSaveData) {
        ensureDirectories()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        if let data = try? encoder.encode(state) {
            try? data.write(to: saveFileURL, options: [.atomic])
        }
    }

    func photoURL(for fileName: String) -> URL {
        photosDirectoryURL.appendingPathComponent(fileName)
    }

    func savePhotoImage(_ image: UIImage) -> String? {
        ensureDirectories()
        guard let data = image.pngData() else { return nil }
        let fileName = "photo_\(Int(Date().timeIntervalSince1970 * 1000)).png"
        let url = photoURL(for: fileName)
        do {
            try data.write(to: url, options: [.atomic])
            return fileName
        } catch {
            return nil
        }
    }

    func loadPhotoImage(named fileName: String) -> UIImage? {
        let url = photoURL(for: fileName)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    func deletePhoto(named fileName: String) {
        let url = photoURL(for: fileName)
        if fileManager.fileExists(atPath: url.path) {
            try? fileManager.removeItem(at: url)
        }
    }
}
