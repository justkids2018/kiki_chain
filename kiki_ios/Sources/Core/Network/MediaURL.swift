import Foundation

/// Old scene records still contain the retired HTTP image host. The same
/// objects are served with a valid certificate by the current media host.
enum MediaURL {
    nonisolated static func resolve(_ raw: String?) -> URL? {
        guard let raw, !raw.isEmpty,
              var components = URLComponents(string: raw) else { return nil }
        if components.host?.lowercased() == "img.mtrain.xyz" {
            components.scheme = "https"
            components.host = "img.keepthinking.me"
        }
        guard components.scheme?.lowercased() == "https" else { return nil }
        return components.url
    }
}
