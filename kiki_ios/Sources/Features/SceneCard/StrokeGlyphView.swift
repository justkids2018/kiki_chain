import SwiftUI

private struct StrokeGlyphData: Decodable {
    let strokes: [String]
    let medians: [[[Double]]]
}

@MainActor
private struct StrokeGlyphDrawing {
    let strokes: [Path]
    let medians: [Path]

    init(data: StrokeGlyphData) {
        strokes = data.strokes.map(Self.svgPath)
        medians = data.medians.map { points in
            var path = Path()
            for (index, point) in points.enumerated() where point.count >= 2 {
                let p = CGPoint(x: point[0], y: point[1])
                if index == 0 { path.move(to: p) } else { path.addLine(to: p) }
            }
            return path
        }
    }

    func fitted(to size: CGSize) -> (strokes: [Path], medians: [Path]) {
        let bounds = strokes.reduce(CGRect.null) { $0.union($1.boundingRect) }
        guard !bounds.isNull, bounds.width > 0, bounds.height > 0 else { return ([], []) }
        let scale = min((size.width - 14) / bounds.width, (size.height - 14) / bounds.height)
        let dx = (size.width - bounds.width * scale) / 2 - bounds.minX * scale
        // Hanzi Writer uses a bottom-left origin; SwiftUI paths use top-left.
        let dy = (size.height - bounds.height * scale) / 2 + bounds.maxY * scale
        let transform = CGAffineTransform(a: scale, b: 0, c: 0, d: -scale, tx: dx, ty: dy)
        return (strokes.map { $0.applying(transform) }, medians.map { $0.applying(transform) })
    }

    private enum Token {
        case command(Character)
        case number(CGFloat)
    }

    private static func svgPath(_ source: String) -> Path {
        let expression = try? NSRegularExpression(pattern: "([MLQCZ])|(-?[0-9]+(?:\\.[0-9]+)?)")
        let nsSource = source as NSString
        let tokens: [Token] = expression?.matches(in: source, range: NSRange(location: 0, length: nsSource.length)).compactMap { match in
            if match.range(at: 1).location != NSNotFound {
                return .command(Character(nsSource.substring(with: match.range(at: 1))))
            }
            return Double(nsSource.substring(with: match.range(at: 2)))
                .map { Token.number(CGFloat($0)) }
        } ?? []

        var path = Path()
        var cursor = 0
        var command: Character?
        var current = CGPoint.zero
        while cursor < tokens.count {
            if case let .command(next) = tokens[cursor] {
                command = next
                cursor += 1
                if next == "Z" { path.closeSubpath(); continue }
            }
            guard let command else { break }
            var values: [CGFloat] = []
            while cursor < tokens.count {
                if case .number(let value) = tokens[cursor] {
                    values.append(value)
                    cursor += 1
                } else { break }
            }
            switch command {
            case "M":
                guard values.count >= 2 else { continue }
                current = CGPoint(x: values[0], y: values[1])
                path.move(to: current)
                for offset in stride(from: 2, to: values.count - 1, by: 2) {
                    current = CGPoint(x: values[offset], y: values[offset + 1])
                    path.addLine(to: current)
                }
            case "L":
                for offset in stride(from: 0, to: values.count - 1, by: 2) {
                    current = CGPoint(x: values[offset], y: values[offset + 1])
                    path.addLine(to: current)
                }
            case "Q":
                for offset in stride(from: 0, to: values.count - 3, by: 4) {
                    let control = CGPoint(x: values[offset], y: values[offset + 1])
                    current = CGPoint(x: values[offset + 2], y: values[offset + 3])
                    path.addQuadCurve(to: current, control: control)
                }
            case "C":
                for offset in stride(from: 0, to: values.count - 5, by: 6) {
                    let first = CGPoint(x: values[offset], y: values[offset + 1])
                    let second = CGPoint(x: values[offset + 2], y: values[offset + 3])
                    current = CGPoint(x: values[offset + 4], y: values[offset + 5])
                    path.addCurve(to: current, control1: first, control2: second)
                }
            default:
                break
            }
        }
        return path
    }
}

private struct StrokePathShape: Shape {
    let pathValue: Path
    func path(in rect: CGRect) -> Path { pathValue }
}

enum GlyphPlaybackState: String {
    case waiting, playing, finished
}

private enum StrokeAnimationTiming {
    // Flutter's matching TianZiGeChar uses animationSpeed = 2.0.
    // Keep the native pace close to that faster learning mode.
    static let strokeDuration: Double = 0.24
    static let pauseBetweenStrokes: UInt64 = 40_000_000
}

struct StrokeGlyphCell: View {
    let character: String
    let state: GlyphPlaybackState
    let replayToken: Int
    var size: CGFloat = 84
    let onTap: () -> Void
    let onAnimationComplete: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            StrokeDrawing(character: character, state: state, replayToken: replayToken,
                          onAnimationComplete: onAnimationComplete)
                .frame(width: size, height: size)
                .background(Color(red: 1, green: 0.976, blue: 0.941))
                .overlay(Rectangle().stroke(Color(red: 0.88, green: 0.75, blue: 0.63), lineWidth: 1.2))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("播放「\(character)」的笔顺")
    }
}

/// Plays each character to completion before activating the next cell.
/// Eager rows keep later cells mounted even when the learning panel scrolls.
struct StrokeGlyphSequenceView: View {
    let characters: [String]
    let onSpeak: (String) -> Void
    @State private var activeIndex = 0
    @State private var replayToken = 0

    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<((characters.count + 1) / 2), id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach((row * 2)..<min(row * 2 + 2, characters.count), id: \.self) { index in
                        let state: GlyphPlaybackState = index < activeIndex ? .finished : (index == activeIndex ? .playing : .waiting)
                        StrokeGlyphCell(
                            character: characters[index],
                            state: state,
                            replayToken: replayToken,
                            size: 90,
                            onTap: {
                                onSpeak(characters[index])
                                activeIndex = index
                                replayToken += 1
                            },
                            onAnimationComplete: {
                                guard activeIndex == index else { return }
                                activeIndex += 1
                            }
                        )
                    }
                    if row * 2 + 1 >= characters.count { Spacer().frame(width: 90) }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct StrokeDrawing: View {
    let character: String
    let state: GlyphPlaybackState
    let replayToken: Int
    let onAnimationComplete: () -> Void
    @State private var drawing: StrokeGlyphDrawing?
    @State private var revealedCount = 0
    @State private var revealProgress: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let fitted = drawing?.fitted(to: proxy.size)
            ZStack {
                TianZiGrid()
                if let fitted, state == .finished {
                    ForEach(fitted.strokes.indices, id: \.self) { index in
                        StrokePathShape(pathValue: fitted.strokes[index])
                            .fill(Color.black.opacity(0.82))
                    }
                } else if let fitted, state == .playing {
                    ForEach(0..<min(revealedCount, fitted.strokes.count), id: \.self) { index in
                        StrokePathShape(pathValue: fitted.strokes[index])
                            .fill(Color.black.opacity(0.82))
                    }
                    if revealedCount < fitted.strokes.count,
                       fitted.medians.indices.contains(revealedCount) {
                        StrokePathShape(pathValue: fitted.medians[revealedCount])
                            .trim(from: 0, to: revealProgress)
                            .stroke(Color.black.opacity(0.88), style: StrokeStyle(lineWidth: max(2, proxy.size.width * 0.052), lineCap: .round, lineJoin: .round))
                    }
                } else if state == .playing || state == .finished {
                    Text(character)
                        .font(.system(size: 40, weight: .regular, design: .serif))
                        .foregroundStyle(.black.opacity(0.8))
                }
            }
        }
        .task(id: "\(character)-\(state.rawValue)-\(replayToken)") {
            guard state == .playing else { return }
            await playStrokeSequence()
        }
    }

    @MainActor private func playStrokeSequence() async {
        if drawing == nil {
            drawing = await KikiResources.strokeGlyphData(for: character).map(StrokeGlyphDrawing.init)
        }
        guard !Task.isCancelled else { return }
        revealedCount = 0
        revealProgress = 0
        guard let drawing, !drawing.strokes.isEmpty else {
            onAnimationComplete()
            return
        }
        for index in drawing.strokes.indices {
            guard !Task.isCancelled else { return }
            if drawing.medians.indices.contains(index) {
                withAnimation(.linear(duration: StrokeAnimationTiming.strokeDuration)) { revealProgress = 1 }
                do {
                    try await Task.sleep(nanoseconds: UInt64(StrokeAnimationTiming.strokeDuration * 1_000_000_000))
                } catch { return }
            }
            guard !Task.isCancelled else { return }
            revealedCount = index + 1
            revealProgress = 0
            if index + 1 < drawing.strokes.count {
                do {
                    try await Task.sleep(nanoseconds: StrokeAnimationTiming.pauseBetweenStrokes)
                } catch { return }
            }
        }
        guard !Task.isCancelled else { return }
        onAnimationComplete()
    }
}

extension KikiResources {
    fileprivate static func strokeGlyphData(for character: String) async -> StrokeGlyphData? {
        guard let scalar = character.unicodeScalars.first else { return nil }
        let name = String(format: "%04x", scalar.value)
        if let url = bundle.url(forResource: name, withExtension: "json", subdirectory: "stroke_order")
                ?? bundle.url(forResource: name, withExtension: "json", subdirectory: "Resources/stroke_order")
                ?? bundle.url(forResource: name, withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let parsed = try? JSONDecoder().decode(StrokeGlyphData.self, from: data) { return parsed }

        let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("stroke_order", isDirectory: true)
        let cachedFile = cache.appendingPathComponent(name).appendingPathExtension("json")
        if let data = try? Data(contentsOf: cachedFile),
           let parsed = try? JSONDecoder().decode(StrokeGlyphData.self, from: data) { return parsed }

        for host in ["https://cdn.jsdelivr.net/npm/hanzi-writer-data@2.0.1/",
                     "https://unpkg.com/hanzi-writer-data@2.0.1/"] {
            guard let url = URL(string: host)?.appendingPathComponent(character).appendingPathExtension("json"),
                  let (data, response) = try? await URLSession.shared.data(from: url),
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  let parsed = try? JSONDecoder().decode(StrokeGlyphData.self, from: data) else { continue }
            try? FileManager.default.createDirectory(at: cache, withIntermediateDirectories: true)
            try? data.write(to: cachedFile, options: .atomic)
            return parsed
        }
        return nil
    }
}

private struct TianZiGrid: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                path.move(to: CGPoint(x: proxy.size.width / 2, y: 0))
                path.addLine(to: CGPoint(x: proxy.size.width / 2, y: proxy.size.height))
                path.move(to: CGPoint(x: 0, y: proxy.size.height / 2))
                path.addLine(to: CGPoint(x: proxy.size.width, y: proxy.size.height / 2))
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: proxy.size.width, y: proxy.size.height))
                path.move(to: CGPoint(x: proxy.size.width, y: 0))
                path.addLine(to: CGPoint(x: 0, y: proxy.size.height))
            }
            .stroke(Color(red: 0.88, green: 0.75, blue: 0.63).opacity(0.48), style: StrokeStyle(lineWidth: 0.7, dash: [3, 2]))
        }
    }
}
