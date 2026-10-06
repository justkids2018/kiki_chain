import SwiftUI
import UIKit

public struct WritingPracticeWord: Identifiable {
    public let id: String
    public let pinyin: String
    public init(id: String, pinyin: String = "") { self.id = id; self.pinyin = pinyin }
}

public struct WritingPracticeView: View {
    let title: String
    let words: [InteractiveRegion]
    @Environment(\.dismiss) private var dismiss
    @State private var shareURL: URL?
    @State private var showShare = false

    public init(title: String, words: [InteractiveRegion]) { self.title = title; self.words = words }

    private var characters: [(String, String)] {
        words.flatMap { word in Array(word.text).enumerated().map { index, char in
            let py = word.textPinyin.split(separator: " ").map(String.init)
            return (String(char), index < py.count ? py[index] : word.textPinyin)
        }}
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                practicePaper
                    .padding(16)
            }
            .background(Color(red: 0.97, green: 0.95, blue: 0.96))
            .navigationTitle(title.isEmpty ? "每日一练" : "每日一练 - \(title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("关闭") { dismiss() } }
                ToolbarItem(placement: .primaryAction) {
                    Button { exportPDF() } label: { Label("打印 / 导出", systemImage: "printer") }
                        .disabled(characters.isEmpty)
                }
            }
            .sheet(isPresented: $showShare) {
                if let shareURL { ActivitySheet(items: [shareURL]) }
            }
        }
    }

    private var practicePaper: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack { Text("每日一练").font(.system(size: 24, weight: .bold)); Spacer(); Text("\(title)").foregroundStyle(.secondary) }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 5), spacing: 12) {
                ForEach(Array(characters.enumerated()), id: \.offset) { _, entry in
                    VStack(spacing: 3) {
                        Text(entry.1.isEmpty ? "　" : entry.1).font(.system(size: 10)).foregroundStyle(.pink)
                        TianZiCell(character: entry.0, ghost: false)
                        TianZiCell(character: entry.0, ghost: true)
                    }
                }
            }
            HStack { Text("日期：________________").foregroundStyle(.pink); Spacer(); Text("评分：☆☆☆☆☆").foregroundStyle(.pink) }.font(.caption)
        }
        .padding(18)
        .frame(maxWidth: 700, minHeight: 850, alignment: .topLeading)
        .background(.white)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.pink.opacity(0.35), lineWidth: 1.5))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 5)
        .frame(maxWidth: .infinity)
    }

    @MainActor private func exportPDF() {
        let renderer = ImageRenderer(content: practicePaper.frame(width: 595, height: 842).padding(10))
        renderer.scale = 2
        guard let data = renderer.uiImage?.pngData() else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("kiki-writing-practice-\(UUID().uuidString).png")
        do { try data.write(to: url); shareURL = url; showShare = true } catch { }
    }
}

private struct TianZiCell: View {
    let character: String
    let ghost: Bool
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Rectangle().stroke(Color.pink.opacity(0.55), lineWidth: 1)
                Path { p in
                    p.move(to: CGPoint(x: 0, y: proxy.size.height / 2)); p.addLine(to: CGPoint(x: proxy.size.width, y: proxy.size.height / 2))
                    p.move(to: CGPoint(x: proxy.size.width / 2, y: 0)); p.addLine(to: CGPoint(x: proxy.size.width / 2, y: proxy.size.height))
                    p.move(to: .zero); p.addLine(to: CGPoint(x: proxy.size.width, y: proxy.size.height))
                    p.move(to: CGPoint(x: proxy.size.width, y: 0)); p.addLine(to: CGPoint(x: 0, y: proxy.size.height))
                }.stroke(Color.pink.opacity(0.30), style: StrokeStyle(lineWidth: 0.7, dash: [3, 2]))
                Text(character).font(.system(size: proxy.size.width * 0.66, weight: .regular, design: .serif))
                    .foregroundStyle(ghost ? Color.pink.opacity(0.18) : Color.primary)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

private struct ActivitySheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController { UIActivityViewController(activityItems: items, applicationActivities: nil) }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
