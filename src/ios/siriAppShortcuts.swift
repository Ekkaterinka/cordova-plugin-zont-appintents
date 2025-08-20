import AppIntents

@available(iOS 16.0, *)
struct AppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        [
            AppShortcut(
                intent: DeviceActionIntent(),
                phrases: [
                    "Выполнить действие с устройством"
                ],
                shortTitle: "Устройства",
            )
        ]
    }
}