import AppIntents

@available(iOS 18.0, *)
struct ShortcutsProvider: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor? = .blue

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: VehicleGuardActionIntent(),
            phrases: [
                "\(.applicationName) Управление состоянием охраны автомобиля"
            ],
            shortTitle: "Управление охраной автомобиля",
            systemImageName: "car.side.lock.fill"
        );
        AppShortcut(
            intent: VehicleStartActionIntent(),
            phrases: [
                    "\(.applicationName) Запуск двигателя автомобиля"
                ],
            shortTitle: "Запуск двигателя автомобиля",
            systemImageName: "car.circle.fill"
        );
        AppShortcut(
            intent: VehicleSirenActionIntent(),
            phrases: [
                    "\(.applicationName) Управление звуковой сигнализацией"
                ],
            shortTitle: "Управление звуковой сигнализацией",
            systemImageName: "car.top.radiowaves.rear.left.car.top.front.fill"
        );
        AppShortcut(
            intent: VehicleBlockActionIntent(),
            phrases: [
                    "\(.applicationName) Блокировка двигателя"
                ],
            shortTitle: "Блокировка двигателя",
            systemImageName: "car.rear.and.tire.marks.slash"
        );
    }
}