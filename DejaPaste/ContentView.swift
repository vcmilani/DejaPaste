import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var vm = EditorViewModel()

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            editor
            statusBar
        }
        .ignoresSafeArea(.container, edges: .top)
        .background(
            ZStack {
                Color(NSColor.windowBackgroundColor)
                LinearGradient(
                    colors: [Color.white.opacity(0.05), Color.black.opacity(0.07)],
                    startPoint: .top, endPoint: .bottom
                )
            }
            .ignoresSafeArea()
        )
        .overlay(alignment: .top) { toast }
        .focusedSceneValue(\.editor, vm)
    }

    private var toolbar: some View {
        HStack(spacing: 12) {
            Text("Déjà Paste")
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer(minLength: 12)

            Button(action: vm.pasteFromClipboard) {
                Label("Colar puro", systemImage: "clipboard")
            }
            .buttonStyle(PillButtonStyle(kind: .prominent))
            .help("Colar do clipboard removendo toda formatação (⌘V)")

            Button(action: vm.copyToClipboard) {
                Label("Copiar", systemImage: "doc.on.doc")
            }
            .buttonStyle(PillButtonStyle(kind: .standard))
            .help("Copiar texto puro para o clipboard (⌘C)")
            .disabled(vm.text.isEmpty)

            Button(action: vm.clear) {
                Label("Limpar", systemImage: "trash")
            }
            .buttonStyle(PillButtonStyle(kind: .destructive))
            .help("Limpar todo o texto (⌘⌫)")
            .disabled(vm.text.isEmpty)
        }
        .padding(.leading, 72)
        .padding(.trailing, 16)
        .padding(.top, 6)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private var editor: some View {
        PlainTextEditor(text: $vm.text)
            .overlay {
                if vm.text.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "doc.on.clipboard")
                            .font(.system(size: 34, weight: .light))
                        Text("Cole seu texto aqui")
                            .font(.title3.weight(.medium))
                        Text("a formatação será removida automaticamente")
                            .font(.callout)
                    }
                    .foregroundStyle(.secondary)
                    .allowsHitTesting(false)
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: vm.text.isEmpty)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(.primary.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.10), radius: 8, y: 2)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var statusBar: some View {
        HStack(spacing: 8) {
            statChip("character", vm.charCount)
            statChip("text.word.spacing", vm.wordCount)
            statChip("line.3.horizontal", vm.lineCount)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private var toast: some View {
        if vm.showFeedback {
            HStack(spacing: 6) {
                Image(systemName: vm.feedbackIcon)
                Text(vm.feedbackMessage)
            }
            .font(.callout.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.12)))
            .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
            .padding(.top, 10)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private func statChip(_ icon: String, _ value: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text("\(value)")
                .monospacedDigit()
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(.quaternary, in: Capsule())
    }
}

struct PillButtonStyle: ButtonStyle {
    enum Kind { case prominent, standard, destructive }

    var kind: Kind = .standard
    @Environment(\.isEnabled) private var isEnabled
    @State private var hovering = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .foregroundStyle(foreground)
            .background(background(pressed: configuration.isPressed))
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(borderColor, lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(isEnabled ? 1 : 0.45)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.12), value: hovering)
            .onHover { hovering = $0 }
    }

    private var foreground: Color {
        switch kind {
        case .prominent: return .white
        case .standard: return .primary
        case .destructive: return .red
        }
    }

    private var borderColor: Color {
        switch kind {
        case .prominent: return .clear
        case .standard: return .primary.opacity(0.12)
        case .destructive: return .red.opacity(0.35)
        }
    }

    @ViewBuilder
    private func background(pressed: Bool) -> some View {
        switch kind {
        case .prominent:
            Color.accentColor.opacity(pressed ? 0.85 : (hovering ? 1 : 0.95))
        case .standard:
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                Color.primary.opacity(hovering ? 0.08 : 0)
            }
        case .destructive:
            Color.red.opacity(hovering ? 0.16 : 0.10)
        }
    }
}
