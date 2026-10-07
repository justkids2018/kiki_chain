import Foundation
import Combine

import AVFoundation

/// 原生语音录音管理器（用于跟读练习、发音评测与 AI 互动）
@MainActor
public final class AudioRecorderManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    public static let shared = AudioRecorderManager()

    @Published public private(set) var isRecording: Bool = false
    @Published public private(set) var recordingDuration: TimeInterval = 0
    @Published public private(set) var lastRecordingURL: URL?

    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?

    private override init() {
        super.init()
    }

    /// 开始录音
    public func startRecording() async -> Bool {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
            try session.setActive(true)
        } catch {
            print("⚠️ 麦克风 Session 配置失败: \(error)")
            return false
        }
        #endif

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("kiki_record_\(UUID().uuidString).m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            let recorder = try AVAudioRecorder(url: fileURL, settings: settings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            guard recorder.record() else { return false }

            self.audioRecorder = recorder
            self.lastRecordingURL = fileURL
            self.isRecording = true
            self.recordingDuration = 0

            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self = self, self.isRecording else { return }
                    self.recordingDuration += 0.1
                }
            }
            return true
        } catch {
            print("⚠️ 创建录音器失败: \(error)")
            return false
        }
    }

    /// 停止录音并返回录音文件地址
    public func stopRecording() -> URL? {
        timer?.invalidate()
        timer = nil

        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false

        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false)
        #endif

        return lastRecordingURL
    }

    /// 取消录音
    public func cancelRecording() {
        timer?.invalidate()
        timer = nil

        audioRecorder?.stop()
        if let url = lastRecordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        audioRecorder = nil
        isRecording = false
        lastRecordingURL = nil
    }

    public nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            self.isRecording = false
        }
    }
}
