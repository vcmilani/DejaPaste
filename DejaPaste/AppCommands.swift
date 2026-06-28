import SwiftUI

extension Notification.Name {
    static let pasteAsPlain = Notification.Name("pasteAsPlain")
    static let copyPlain = Notification.Name("copyPlain")
    static let clearAll = Notification.Name("clearAll")
}

struct AppCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("Nova Aba") {
                let existingWindow = NSApp.keyWindow
                let windowsBefore = Set(NSApp.windows)

                NSApp.sendAction(#selector(NSResponder.newWindowForTab(_:)), to: nil, from: nil)

                DispatchQueue.main.async {
                    if let newWindow = Set(NSApp.windows).subtracting(windowsBefore).first,
                       let existingWindow = existingWindow {
                        existingWindow.addTabbedWindow(newWindow, ordered: .above)
                        newWindow.makeKeyAndOrderFront(nil)
                    }
                }
            }
            .keyboardShortcut("t", modifiers: .command)
        }

        // Replace the default Edit menu paste with our plain paste
        CommandGroup(replacing: .pasteboard) {
            Button("Déjà Paste — Colar puro") {
                NotificationCenter.default.post(name: .pasteAsPlain, object: nil)
            }
            .keyboardShortcut("v", modifiers: .command)

            Button("Copiar") {
                NotificationCenter.default.post(name: .copyPlain, object: nil)
            }
            .keyboardShortcut("c", modifiers: .command)

            Divider()

            Button("Limpar tudo") {
                NotificationCenter.default.post(name: .clearAll, object: nil)
            }
            .keyboardShortcut(.delete, modifiers: .command)
        }
    }
}
