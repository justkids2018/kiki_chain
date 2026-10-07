import Foundation
import SwiftUI
import AVFoundation
import UIKit
import CoreText

/// 统一资源定位与加载管理器（兼容 SPM Bundle.module 与主 App Bundle.main）
public enum KikiResources {
    public static func registerFonts() {
        ["Fredoka-Regular", "Fredoka-SemiBold", "Nunito-Regular", "Nunito-Bold", "AR-PL-KaitiM-GB"].forEach { name in
            guard let url = bundle.url(forResource: name, withExtension: "ttf") else { return }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    public static var bundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle.main
        #endif
    }

    /// Load an image copied from the Flutter asset bundle into the native app bundle.
    public static func image(named name: String, extension ext: String = "png") -> Image? {
        guard let url = bundle.url(forResource: name, withExtension: ext)
                ?? bundle.url(forResource: name, withExtension: ext, subdirectory: "images"),
              let image = UIImage(contentsOfFile: url.path) else { return nil }
        return Image(uiImage: image)
    }

    /// 获取音频资源 URL
    public static func audioURL(named name: String) -> URL? {
        let cleanName = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension.isEmpty ? "mp3" : (name as NSString).pathExtension

        // 尝试直接查找
        if let url = bundle.url(forResource: cleanName, withExtension: ext) {
            return url
        }
        // 尝试在 audio 子目录下查找
        if let url = bundle.url(forResource: cleanName, withExtension: ext, subdirectory: "audio") {
            return url
        }
        if let url = bundle.url(forResource: cleanName, withExtension: ext, subdirectory: "Resources/audio") {
            return url
        }
        return nil
    }

    /// Resolve a bundled legal/document resource whether Xcode flattened it or preserved its folder.
    public static func resourceURL(named name: String, extension ext: String, subdirectory: String? = nil) -> URL? {
        if let subdirectory, let url = bundle.url(forResource: name, withExtension: ext, subdirectory: subdirectory) { return url }
        return bundle.url(forResource: name, withExtension: ext)
    }

    /// 获取内置场景卡片 JSON 数据
    public static func sceneDataURL(named name: String) -> URL? {
        let component = URL(string: name)?.lastPathComponent ?? name
        let cleanName = (component as NSString).deletingPathExtension
        return bundle.url(forResource: cleanName, withExtension: "json") ??
               bundle.url(forResource: cleanName, withExtension: "json", subdirectory: "Resources")
    }

    /// Read and normalize the flat or grouped hotspot JSON used by kiki_web.
    public static func interactiveRegions(named name: String) -> [InteractiveRegion] {
        guard let url = sceneDataURL(named: name),
              let data = try? Data(contentsOf: url),
              let json = try? JSONDecoder().decode(JSONValue.self, from: data),
              let items = json.arrayValue else { return [] }
        return InteractiveRegion.parse(itemsData: items)
    }

    /// 播放获得星星音效 (1, 2, 3)
    @MainActor
    public static func playStarSound(star: Int) {
        let soundName = star >= 3 ? "star_3_complete" : "star_\(star)"
        if let url = audioURL(named: soundName) {
            AudioPlayerManager.shared.play(url: url)
        }
    }
}
