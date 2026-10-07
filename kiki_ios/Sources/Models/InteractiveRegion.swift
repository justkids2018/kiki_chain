import Foundation

/// A tappable vocabulary region from the legacy Flutter JSON or mobile API.
public struct InteractiveRegion: Codable, Identifiable, Hashable {
    public let type: String
    public let id: String
    public let index: Int
    public let text: String
    public let textPinyin: String
    public let textEnglish: String
    public let textPhonetic: String
    public let audioCnKey: String
    public let audioCnUrl: String
    public let audioEnKey: String
    public let audioEnUrl: String
    public let audioSourceType: String
    /// Polygon vertices in the source image's pixel coordinates.
    public let coordinates: [Point]

    public struct Point: Codable, Hashable {
        public let x: Double
        public let y: Double
        public init(x: Double, y: Double) { self.x = x; self.y = y }
    }

    private enum CodingKeys: String, CodingKey {
        case type, id, index, text, coordinate, coordinates
        case textPinyin = "text_pinyin"
        case textEnglish = "text_english"
        case textPhonetic = "text_phonetic"
        case audioCnKey = "audio_cn_key"
        case audioCnUrl = "audio_cn_url"
        case audioUrl = "audio_url"
        case audioEnKey = "audio_en_key"
        case audioEnUrl = "audio_en_url"
        case audioSourceType = "audio_source_type"
        case audioCnKeyCamel = "audioCnKey"
        case audioCnUrlCamel = "audioCnUrl"
        case audioEnKeyCamel = "audioEnKey"
        case audioEnUrlCamel = "audioEnUrl"
        case audioSourceTypeCamel = "playback_type"
    }

    private enum AliasKeys: String, CodingKey {
        case nestedRegions = "regions"
    }

    public init(
        type: String = "chinese", id: String, index: Int = 0, text: String,
        textPinyin: String = "", textEnglish: String = "", textPhonetic: String = "",
        audioCnKey: String = "", audioCnUrl: String = "", audioEnKey: String = "",
        audioEnUrl: String = "", audioSourceType: String = "tts", coordinates: [Point] = []
    ) {
        self.type = type
        self.id = id
        self.index = index
        self.text = text
        self.textPinyin = textPinyin
        self.textEnglish = textEnglish
        self.textPhonetic = textPhonetic
        self.audioCnKey = audioCnKey
        self.audioCnUrl = audioCnUrl
        self.audioEnKey = audioEnKey
        self.audioEnUrl = audioEnUrl
        self.audioSourceType = audioSourceType
        self.coordinates = coordinates
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decodeIfPresent(String.self, forKey: .type) ?? "chinese"
        id = try values.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        index = try values.decodeIfPresent(Int.self, forKey: .index) ?? 0
        text = try values.decodeIfPresent(String.self, forKey: .text) ?? ""
        textPinyin = try values.decodeIfPresent(String.self, forKey: .textPinyin) ?? ""
        textEnglish = try values.decodeIfPresent(String.self, forKey: .textEnglish) ?? ""
        textPhonetic = try values.decodeIfPresent(String.self, forKey: .textPhonetic) ?? ""
        audioCnKey = try values.decodeIfPresent(String.self, forKey: .audioCnKey)
            ?? values.decodeIfPresent(String.self, forKey: .audioCnKeyCamel) ?? ""
        audioCnUrl = try values.decodeIfPresent(String.self, forKey: .audioCnUrl)
            ?? values.decodeIfPresent(String.self, forKey: .audioCnUrlCamel)
            ?? values.decodeIfPresent(String.self, forKey: .audioUrl) ?? ""
        audioEnKey = try values.decodeIfPresent(String.self, forKey: .audioEnKey)
            ?? values.decodeIfPresent(String.self, forKey: .audioEnKeyCamel) ?? ""
        audioEnUrl = try values.decodeIfPresent(String.self, forKey: .audioEnUrl)
            ?? values.decodeIfPresent(String.self, forKey: .audioEnUrlCamel) ?? ""
        audioSourceType = try values.decodeIfPresent(String.self, forKey: .audioSourceType)
            ?? values.decodeIfPresent(String.self, forKey: .audioSourceTypeCamel) ?? ""
        coordinates = try values.decodeIfPresent([Point].self, forKey: .coordinate)
            ?? values.decodeIfPresent([Point].self, forKey: .coordinates) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(type, forKey: .type)
        try values.encode(id, forKey: .id)
        try values.encode(index, forKey: .index)
        try values.encode(text, forKey: .text)
        try values.encode(textPinyin, forKey: .textPinyin)
        try values.encode(textEnglish, forKey: .textEnglish)
        try values.encode(textPhonetic, forKey: .textPhonetic)
        try values.encode(audioCnKey, forKey: .audioCnKey)
        try values.encode(audioCnUrl, forKey: .audioCnUrl)
        try values.encode(audioEnKey, forKey: .audioEnKey)
        try values.encode(audioEnUrl, forKey: .audioEnUrl)
        try values.encode(audioSourceType, forKey: .audioSourceType)
        try values.encode(coordinates, forKey: .coordinate)
    }

    public static func parse(itemsData: [JSONValue]) -> [InteractiveRegion] {
        let decoder = JSONDecoder()
        var result: [InteractiveRegion] = []
        for item in itemsData {
            guard let object = item.objectValue,
                  let data = try? JSONEncoder().encode(item) else { continue }
            if let nested = object["regions"]?.arrayValue {
                for (offset, region) in nested.enumerated() {
                    guard var merged = region.objectValue else { continue }
                    for (key, value) in object where merged[key] == nil && key != "regions" {
                        merged[key] = value
                    }
                    if merged["id"] == nil {
                        merged["id"] = .string("\(object["id"]?.stringValue ?? "region")_\(offset + 1)")
                    }
                    if let mergedData = try? JSONEncoder().encode(JSONValue.object(merged)),
                       let parsed = try? decoder.decode(InteractiveRegion.self, from: mergedData) {
                        result.append(parsed)
                    }
                }
            } else if let parsed = try? decoder.decode(InteractiveRegion.self, from: data) {
                result.append(parsed)
            }
        }
        return result
    }

    public var normalizedAudioSourceType: String {
        if !audioSourceType.isEmpty { return audioSourceType.lowercased() }
        return audioCnUrl.isEmpty && audioEnUrl.isEmpty ? "tts" : "url"
    }
}
