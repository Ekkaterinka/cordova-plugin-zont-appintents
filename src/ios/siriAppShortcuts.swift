import AppIntents

@available(iOS 16.0, *)
struct ShortcutsProvider: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: DeviceActionIntent(),
                phrases: [
                    "Запуск двигателя автомобиля"
                ],
                shortTitle: "Устройства"
        )
    }
}