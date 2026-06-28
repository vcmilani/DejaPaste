import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var vm = EditorViewModel()

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            editor
            Divider()
            statusBar
        }
        .background(Color(NSColor.windowBackgroundColor))
        .onReceive(NotificationCenter.default.publisher(for: .pasteAsPlain)) { _ in
            vm.pasteFromClipboard()
        }
        .onReceive(NotificationCenter.default.publisher(for: .copyPlain)) { _ in
            vm.copyToClipboard()
        }
        .onReceive(NotificationCenter.default.publisher(for: .clearAll)) { _ in
            vm.clear()
        }
    }

    private var toolbar: some View {
        HStack(spacing: 8) {
            Button(action: vm.pasteFromClipboard) {
                Label("Colar puro", systemImage: "clipboard")
            }
            .help("Colar do clipboard removendo toda formatação (⌘V)")

            Button(action: vm.copyToClipboard) {
                Label("Copiar", systemImage: "doc.on.doc")
            }
            .help("Copiar texto puro para o clipboard (⌘C)")
            .disabled(vm.text.isEmpty)

            Divider().frame(height: 20)

            Button(action: vm.clear) {
                Label("Limpar", systemImage: "trash")
            }
            .help("Limpar todo o texto (⌘⌫)")
            .disabled(vm.text.isEmpty)

            Spacer()

            if vm.showFeedback {
                Text(vm.feedbackMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var editor: some View {
        PlainTextEditor(text: $vm.text)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var statusBar: some View {
        HStack {
            Text(vm.statsText)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text("Déjà Paste · texto sem formatação")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}
