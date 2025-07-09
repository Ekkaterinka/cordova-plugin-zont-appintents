import AppIntents

@available(iOS 16.0, *)
struct ShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: siriAppIntent(),
            phrases: ["Открой машину"],
            shortTitle: "Откроет машину",
            systemImageName: "zont"
        )
    }
}