//
//  CatTamagochiApp.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 06.09.2024.
//

import SwiftUI
import SwiftData

@main
struct CatTamagochiApp: App {
    
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            GameView().preferredColorScheme(.light)
        }.onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background:
                // Когда приложение уходит в фон, сохраняем текущую дату
                DateKeeper.saveCurrentDate()
                print("Приложение ушло в фон. Дата сохранена.")
            case .active:
                    print("Приложение снова активно.", DateKeeper.getSecondsDifference())
                // Логика при возвращении в активное состояние
            case .inactive:
                print("Приложение неактивно.")
            default:
                break
            }
        }
    }
}
