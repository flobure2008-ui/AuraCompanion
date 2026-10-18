import SwiftUI

public struct MarkdownTextView: View {
    public let text: String
    public var accentColor: Color = .purple
    
    public init(text: String, accentColor: Color = .purple) {
        self.text = text
        self.accentColor = accentColor
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(parseBlocks(text: text), id: \.id) { block in
                switch block.type {
                case .code(let language, let code):
                    CodeBlockView(language: language, code: code, accentColor: accentColor)
                case .text(let content):
                    if let attributed = try? AttributedString(markdown: content) {
                        Text(attributed)
                            .font(.system(size: 15.5, weight: .regular, design: .default))
                            .lineSpacing(4)
                            .foregroundColor(.white.opacity(0.92))
                    } else {
                        Text(content)
                            .font(.system(size: 15.5, weight: .regular, design: .default))
                            .lineSpacing(4)
                            .foregroundColor(.white.opacity(0.92))
                    }
                }
            }
        }
    }
    
    private struct BlockItem: Identifiable {
        let id = UUID()
        enum BlockType {
            case text(String)
            case code(language: String, code: String)
        }
        let type: BlockType
    }
    
    private func parseBlocks(text: String) -> [BlockItem] {
        var blocks: [BlockItem] = []
        let pattern = "```([a-zA-Z0-9]*)\\n([\\s\\S]*?)```"
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return [BlockItem(type: .text(text))]
        }
        
        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        var currentIndex = 0
        for match in matches {
            if match.range.location > currentIndex {
                let range = NSRange(location: currentIndex, length: match.range.location - currentIndex)
                let textChunk = nsString.substring(with: range).trimmingCharacters(in: .whitespacesAndNewlines)
                if !textChunk.isEmpty {
                    blocks.append(BlockItem(type: .text(textChunk)))
                }
            }
            
            let lang = nsString.substring(with: match.range(at: 1))
            let code = nsString.substring(with: match.range(at: 2)).trimmingCharacters(in: .newlines)
            blocks.append(BlockItem(type: .code(language: lang.isEmpty ? "Code" : lang, code: code)))
            
            currentIndex = match.range.location + match.range.length
        }
        
        if currentIndex < nsString.length {
            let remaining = nsString.substring(from: currentIndex).trimmingCharacters(in: .whitespacesAndNewlines)
            if !remaining.isEmpty {
                blocks.append(BlockItem(type: .text(remaining)))
            }
        }
        
        return blocks.isEmpty ? [BlockItem(type: .text(text))] : blocks
    }
}

public struct CodeBlockView: View {
    public let language: String
    public let code: String
    public var accentColor: Color
    
    @State private var isCopied = false
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(language.uppercased())
                    .font(.caption2.bold())
                    .foregroundColor(accentColor)
                
                Spacer()
                
                Button {
                    UIPasteboard.general.string = code
                    HapticsService.light()
                    withAnimation {
                        isCopied = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isCopied = false
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                        Text(isCopied ? "Copié !" : "Copier")
                    }
                    .font(.caption2.weight(.medium))
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.4))
            
            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .foregroundColor(Color(hex: "E2E8F0"))
                    .padding(14)
            }
        }
        .background(Color(hex: "0A0F1D"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}
