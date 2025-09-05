import AppIntents

@available(iOS 18.0, *)
struct ShortcutsProvider: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor { return .teal}

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: VehicleGuardActionIntentEnable(),
            phrases: [
                "\(.applicationName) Поставить на охрану автомобиль", "Поставить на охрану автомобиль",
                
            ],
            shortTitle: "Поставить на охрану автомобиль",
            systemImageName: "car.side.lock.fill"
        );
        AppShortcut(
            intent: VehicleGuardActionIntentDisable(),
            phrases: [
                "\(.applicationName) Снять с охраны автомобиль", "Снять с охраны автомобиль"
            ],
            shortTitle: "Снять с охраны автомобиль",
            systemImageName: "car.side.lock.open.fill"
        );
        AppShortcut(
            intent: VehicleStartActionIntent(),
            phrases: [
                    "\(.applicationName) Запуск двигателя автомобиля", "Запуск двигателя автомобиля"
                ],
            shortTitle: "Запуск двигателя автомобиля",
            systemImageName: "car.circle.fill"
        );
        AppShortcut(
            intent: VehicleSirenActionIntentOff(),
            phrases: [
                    "\(.applicationName) Выключить сирену"
                ],
            shortTitle: "Выключить сирену",
            systemImageName: "car.top.radiowaves.rear.right.badge.xmark"
        );
        
        AppShortcut(
            intent: VehicleBlockActionIntentActive(),
            phrases: [
                    "\(.applicationName) Включить сирену"
                ],
            shortTitle: "Включить сирену",
            systemImageName: "car.top.radiowaves.rear.right.badge.exclamationmark"
            
        );
        AppShortcut(
            intent: VehicleBlockActionIntentOff(),
            phrases: [
                    "\(.applicationName) Выключить блокировку двигателя"
                ],
            shortTitle: "Выключить блокировку двигателя",
            systemImageName: "engine.combustion.fill"
        );
        AppShortcut(
            intent: VehicleBlockActionIntentActive(),
            phrases: [
                    "\(.applicationName) Включить блокировку двигателя"
                ],
            shortTitle: "Включить блокировку двигателя",
            systemImageName: "engine.combustion.badge.exclamationmark.fill"
        );
        AppShortcut(
            intent: ControlCircuitsActionIntent(),
            phrases: [
                    "\(.applicationName) Установить температуру в контуре отопления"
                ],
            shortTitle: "Установить температуру в контуре отопления",
            systemImageName: "degreesign.celsius"
        );
        AppShortcut(
            intent: ControlModesActionIntent(),
            phrases: [
                    "\(.applicationName) Активация режима отопления"
                ],
            shortTitle: "Активация режима отопления",
            systemImageName: "play.house.fill"
        );
        AppShortcut(
            intent: ControlTriggerActionIntentSimple(),
            phrases: [
                    "\(.applicationName) Активация простой кнопки"
                ],
            shortTitle: "Активация простой кнопки",
            systemImageName: "button.horizontal.top.press"
        );
        AppShortcut(
            intent: ControlTriggerActionIntentComplex(),
            phrases: [
                    "\(.applicationName) Активация сложной кнопки"
                ],
            shortTitle: "Активация сложной кнопки",
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
                    "\(.applicationName) Запуск предустановленного сценария"
                ],
            shortTitle: "Запуск предустановленного сценария",
            systemImageName: "cursorarrow.click.2"
        );
    }
}
