import Foundation
import Combine

import AVFoundation

/// 原生音频播放管理（负责卡片发音、TTS播放与音效反馈）
@MainActor
public final class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate, AVSpeechSynthesizerDelegate {
    public static let shared = AudioPlayerManager()

    @Published public private(set) var isPlaying: Bool = false
    @Published public private(set) var currentAudioURL: URL?

    private var player: AVPlayer?
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var timeObserver: Any?

    private override init() {
        super.init()
        speechSynthesizer.delegate = self
        configureAudioSession()
    }

    private func configureAudioSession() {
        #if os(iOS)
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            print("⚠️ AVAudioSession 配置失败: \(error)")
        }
        #endif
    }

    /// 播放远程或本地音频
    public func play(url: URL) {
        stop()

        currentAudioURL = url
        isPlaying = true

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )

        player?.play()
    }

    /// Native speech fallback for vocabulary without a bundled or remote clip.
    public func speak(_ text: String, language: String = "zh-CN") {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        let speed = UserDefaults.standard.object(forKey: "kiki_voice_speed") as? Double ?? 1.0
        let volume = UserDefaults.standard.object(forKey: "kiki_speech_volume") as? Double ?? 1.0
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * Float(speed)
        utterance.volume = Float(volume)
        isPlaying = true
        speechSynthesizer.speak(utterance)
    }

    /// 停止当前播放
    public func stop() {
        if let currentItem = player?.currentItem {
            NotificationCenter.default.removeObserver(
                self,
                name: .AVPlayerItemDidPlayToEndTime,
                object: currentItem
            )
        }
        player?.pause()
        player = nil
        speechSynthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
        currentAudioURL = nil
    }

    @objc private func playerDidFinishPlaying(notification: Notification) {
        Task { @MainActor in
            self.isPlaying = false
            self.currentAudioURL = nil
        }
    }

    public nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isPlaying = false
        }
    }
}
