import SwiftUI

struct EditorFocusedKey: FocusedValueKey {
    typealias Value = EditorViewModel
}

extension FocusedValues {
    var editor: EditorViewModel? {
        get { self[EditorFocusedKey.self] }
        set { self[EditorFocusedKey.self] = newValue }
    }
}

struct AppCommands: Commands {
    @FocusedValue(\.editor) private var editor

    var body: some Commands {
        // Replace the default Edit menu paste with our plain paste
        CommandGroup(replacing: .pasteboard) {
            Button("Déjà Paste — Colar puro") {
                editor?.pasteFromClipboard()
            }
            .keyboardShortcut("v", modifiers: .command)

            Button("Copiar") {
                editor?.copyToClipboard()
            }
            .keyboardShortcut("c", modifiers: .command)

            Button("Selecionar Tudo") {
                NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
            }
            .keyboardShortcut("a", modifiers: .command)

            Divider()

            Button("Limpar tudo") {
                editor?.clear()
            }
            .keyboardShortcut(.delete, modifiers: .command)
        }
    }
}
