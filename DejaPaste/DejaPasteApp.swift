import SwiftUI
import AppKit

@main
struct DejaPasteApp: App {
    init() {
        NSWindow.allowsAutomaticWindowTabbing = false
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 500, minHeight: 400)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            AppCommands()
        }
    }
}
