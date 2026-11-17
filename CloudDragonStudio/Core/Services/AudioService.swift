import AVFoundation
import Foundation

@MainActor
final class AudioService: ObservableObject {
    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: Self.sfxKey)
        }
    }

    @Published var isMusicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isMusicEnabled, forKey: Self.bgmKey)
            updateMusicPlayback()
        }
    }

    private var bgmPlayer: AVAudioPlayer?
    private var sfxPlayers: [String: AVAudioPlayer] = [:]

    private static let sfxKey = "cloud_dragon_sfx_enabled"
    private static let bgmKey = "cloud_dragon_bgm_enabled"

    init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Self.sfxKey) == nil {
            self.isSoundEnabled = true
        } else {
            self.isSoundEnabled = defaults.bool(forKey: Self.sfxKey)
        }
        if defaults.object(forKey: Self.bgmKey) == nil {
            self.isMusicEnabled = true
        } else {
            self.isMusicEnabled = defaults.bool(forKey: Self.bgmKey)
        }
        configureAudioSession()
        startBackgroundMusicIfNeeded()
    }

    func toggleSound() {
        isSoundEnabled.toggle()
        if isSoundEnabled {
            playPop()
        }
    }

    func toggleMusic() {
        isMusicEnabled.toggle()
    }

    func playPop() {
        playEffect(named: "pop", volume: 0.7)
    }

    func playSparkle() {
        playEffect(named: "sparkle", volume: 0.72)
    }

    func playCheer() {
        playEffect(named: "cheer", volume: 0.8)
    }

    func playBrush() {
        playEffect(named: "brush", volume: 0.45)
    }

    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private func soundURL(named name: String) -> URL? {
        Bundle.main.url(forResource: name, withExtension: "wav")
            ?? Bundle.main.url(forResource: name, withExtension: "wav", subdirectory: "Sounds")
    }

    private func startBackgroundMusicIfNeeded() {
        guard isMusicEnabled else { return }
        if bgmPlayer == nil, let url = soundURL(named: "bgm") {
            let player = try? AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = 0.28
            player?.prepareToPlay()
            bgmPlayer = player
        }
        bgmPlayer?.play()
    }

    private func updateMusicPlayback() {
        if isMusicEnabled {
            startBackgroundMusicIfNeeded()
        } else {
            bgmPlayer?.pause()
        }
    }

    private func playEffect(named name: String, volume: Float) {
        guard isSoundEnabled else { return }
        if let cached = sfxPlayers[name] {
            cached.currentTime = 0
            cached.volume = volume
            cached.play()
            return
        }
        guard let url = soundURL(named: name),
              let player = try? AVAudioPlayer(contentsOf: url) else { return }
        player.volume = volume
        player.prepareToPlay()
        sfxPlayers[name] = player
        player.play()
    }
}
