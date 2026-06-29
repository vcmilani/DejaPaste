import SwiftUI
import AppKit

struct PlainTextEditor: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView

        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.isRichText = false
        textView.importsGraphics = false
        textView.usesAdaptiveColorMappingForDarkAppearance = true

        textView.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.textContainerInset = NSSize(width: 12, height: 12)

        textView.backgroundColor = NSColor.textBackgroundColor
        textView.textColor = NSColor.textColor

        scrollView.drawsBackground = true
        scrollView.backgroundColor = NSColor.textBackgroundColor

        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false

        textView.string = text
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let textView = scrollView.documentView as! NSTextView
        if textView.string != text {
            let sel = textView.selectedRanges
            textView.string = text
            if let first = sel.first as? NSRange, first.location <= text.count {
                textView.selectedRanges = sel
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: PlainTextEditor

        init(_ parent: PlainTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }

        func textView(_ textView: NSTextView, shouldChangeTextIn range: NSRange, replacementString: String?) -> Bool {
            return true
        }

        // Intercept paste to always strip formatting
        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == Selector("paste:") {
                let pasteboard = NSPasteboard.general

                // Try plain text first
                if let plain = pasteboard.string(forType: .string) {
                    textView.insertText(plain, replacementRange: textView.selectedRange())
                    return true
                }

                // Try HTML
                if let html = pasteboard.string(forType: .html),
                   let data = html.data(using: .utf8),
                   let attributed = try? NSAttributedString(
                       data: data,
                       options: [
                           .documentType: NSAttributedString.DocumentType.html,
                           .characterEncoding: String.Encoding.utf8.rawValue
                       ],
                       documentAttributes: nil
                   ) {
                    textView.insertText(attributed.string, replacementRange: textView.selectedRange())
                    return true
                }

                // Try RTF
                if let rtfData = pasteboard.data(forType: .rtf),
                   let attributed = try? NSAttributedString(
                       data: rtfData,
                       options: [.documentType: NSAttributedString.DocumentType.rtf],
                       documentAttributes: nil
                   ) {
                    textView.insertText(attributed.string, replacementRange: textView.selectedRange())
                    return true
                }

                return false
            }
            return false
        }
    }
}
