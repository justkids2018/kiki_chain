import SwiftUI
import WebKit

/// Renders the original SVG UI artwork from kiki_web without replacing it with SF Symbols.
struct KikiSVGImage: UIViewRepresentable {
    let name: String

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView(frame: .zero)
        view.isOpaque = false
        view.backgroundColor = .clear
        view.scrollView.backgroundColor = .clear
        view.scrollView.isScrollEnabled = false
        view.scrollView.contentInsetAdjustmentBehavior = .never
        view.isUserInteractionEnabled = false
        view.loadHTMLString("<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1, maximum-scale=1\"><style>@font-face{font-family:Fredoka;src:url('Fredoka-SemiBold.ttf');font-weight:600 900}@font-face{font-family:Nunito;src:url('Nunito-Bold.ttf');font-weight:600 900}html,body{margin:0;width:100%;height:100%;overflow:hidden;background:transparent}img{width:100%;height:100%;object-fit:contain}</style></head><body><img src=\"\(name).svg\"></body></html>", baseURL: KikiResources.bundle.bundleURL)
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
