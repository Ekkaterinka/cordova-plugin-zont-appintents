import AppIntents

@available(iOS 18.0, *)
struct ShortcutsProvider: AppShortcutsProvider {

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: VehicleGuardActionIntentEnable(),
            phrases: [
                "\(.applicationName) Поставить на охрану автомобиль", "\(.applicationName) Авто под охрану",
                
            ],
            shortTitle: "Авто под охрану",
            systemImageName: "car.side.lock.fill"
        );
        AppShortcut(
            intent: VehicleGuardActionIntentDisable(),
            phrases: [
                "\(.applicationName) Снять с охраны автомобиль", "\(.applicationName) Авто снять с охраны"
            ],
            shortTitle: "Авто снять с охраны",
            systemImageName: "car.side.lock.open.fill"
        );
        AppShortcut(
            intent: VehicleStartActionIntent(),
            phrases: [
                    "\(.applicationName) Запуск двигателя автомобиля", "\(.applicationName) Запуск авто"
                ],
            shortTitle: "Запуск авто",
            systemImageName: "car.circle.fill"
        );
        AppShortcut(
            intent: ControlCircuitsActionIntent(),
            phrases: [
                    "\(.applicationName) Установить температуру в контуре отопления"
                ],
            shortTitle: "t° контура отопления",
            systemImageName: "degreesign.celsius"
        );
        AppShortcut(
            intent: ControlModesActionIntent(),
            phrases: [
                    "\(.applicationName) Активация режима отопления", "\(.applicationName) Активация режима"
                ],
            shortTitle: "Активация режима",
            systemImageName: "play.house.fill"
        );
        AppShortcut(
            intent: ControlTriggerActionIntentComplex(),
            phrases: [
                    "\(.applicationName) Активация кнопки"
                ],
            shortTitle: "Активация кнопки",
            systemImageName: "button.horizontal.top.press.fill"
        );
        AppShortcut(
            intent: ControlGuardActionIntentEnable(),
            phrases: [
                    "\(.applicationName) Поставить на охрану"
                ],
            shortTitle: "Поставить на охрану",
            systemImageName: "lock.fill"
        );
        AppShortcut(
            intent: ControlGuardActionIntentDisable(),
            phrases: [
                    "\(.applicationName) Снять с охраны"
                ],
            shortTitle: "Снять с охраны",
            systemImageName: "lock.open.fill"
        );
        AppShortcut(
            intent: ControlScenariosActionIntent(),
            phrases: [
                    "\(.applicationName) Запуск сценария"
                ],
            shortTitle: "Запуск сценария",
            systemImageName: "cursorarrow.click.2"
        );
    }
}

