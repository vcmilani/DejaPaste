import SwiftUI
import AppKit
import Combine

class EditorViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var showFeedback: Bool = false
    @Published var feedbackMessage: String = ""
    @Published var feedbackIcon: String = "checkmark.circle.fill"

    private var feedbackTimer: AnyCancellable?

    var charCount: Int { text.count }
    var wordCount: Int { text.split(whereSeparator: \.isWhitespace).count }
    var lineCount: Int { text.isEmpty ? 0 : text.components(separatedBy: "\n").count }

    func pasteFromClipboard() {
        let pasteboard = NSPasteboard.general
        if let plain = pasteboard.string(forType: .string) {
            insertText(plain)
            showFeedbackBrief("Colado como texto puro")
        } else if let rtf = pasteboard.string(forType: .rtf) {
            let stripped = stripRTF(rtf)
            insertText(stripped)
            showFeedbackBrief("Formatação removida")
        } else if let html = pasteboard.string(forType: .html) {
            let stripped = stripHTML(html)
            insertText(stripped)
            showFeedbackBrief("Formatação removida")
        } else {
            showFeedbackBrief("Nada para colar", icon: "exclamationmark.circle")
        }
    }

    func copyToClipboard() {
        guard !text.isEmpty else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        showFeedbackBrief("Copiado!")
    }

    func clear() {
        guard !text.isEmpty else { return }
        text = ""
        showFeedbackBrief("Limpo")
    }

    private func insertText(_ newText: String) {
        if text.isEmpty {
            text = newText
        } else {
            text += "\n" + newText
        }
    }

    private func showFeedbackBrief(_ message: String, icon: String = "checkmark.circle.fill") {
        feedbackMessage = message
        feedbackIcon = icon
        withAnimation { showFeedback = true }
        feedbackTimer?.cancel()
        feedbackTimer = Just(())
            .delay(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                withAnimation { self?.showFeedback = false }
            }
    }

    private func stripHTML(_ html: String) -> String {
        guard let data = html.data(using: .utf8),
              let attributed = try? NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
              ) else {
            return html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        }
        return attributed.string
    }

    private func stripRTF(_ rtf: String) -> String {
        guard let data = rtf.data(using: .utf8),
              let attributed = try? NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.rtf],
                documentAttributes: nil
              ) else {
            return rtf
        }
        return attributed.string
    }
}
