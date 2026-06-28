import SwiftUI

@main
struct DejaPasteApp: App {
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
