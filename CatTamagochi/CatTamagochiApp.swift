//
//  CatTamagochiApp.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 06.09.2024.
//

import SwiftUI
import SwiftData
import FastAppLibrary
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        
        let onboarding: [OnBoardingModel] = [
            .init(
                image: "1",
                title: "Your AI Pet",
                subTitle: "Create and take care of your cat."
            ),
            .init(
                image: "2",
                title: "Console",
                subTitle: "Type commands to interact with your cat. You can feed, play, and engage with your pet through simple inputs."
            ),
            .init(
                image: "3",
                title: "Commands",
                subTitle: "Start typing, and suggestions will guide you to the available commands."
            ),
            .init(
                image: "3",
                title: "Market",
                subTitle: "Purchase items for your pet. Each item unlocks new commands and features!"
            ),
            .init(
                image: "3",
                title: "Parameters",
                subTitle: "Keep an eye on your pet's stats to ensure it's not hungry or bored."
            ),
            .init(
                image: "3",
                title: "Intelligence",
                subTitle: "Your cat remembers everything you do with it. Tap on it to find out what it’s thinking."
            )
        ]
        
        let benefits: [PaywallBenefitItem] = [
            .init(
                systemIcon: "wand.and.stars.inverse",
                  title: "Access unlimited editor features",
                  subtitle: "Add new commands to the console or modify existing ones."
            ),
            .init(
                systemIcon: "icloud.and.arrow.up.fill",
                  title: "Creative freedom",
                  subtitle: "Choose animations and sounds—complete creative freedom! You can even share your custom commands with us, and they might appear in future updates."
            ),
            .init(
                systemIcon: "icloud.and.arrow.up.fill",
                  title: "Pet’s attributes",
                  subtitle: "Edit your pet’s attributes like hunger, intelligence, mood, and more—no restrictions."
            ),
            .init(
                systemIcon: "icloud.and.arrow.up.fill",
                  title: "Pet’s memory.",
                  subtitle: "Modify your pet’s memory. If you want it to forget something unpleasant, the editor will help you."
            ),
            .init(
                systemIcon: "icloud.and.arrow.up.fill",
                  title: "Money",
                  subtitle: "Add unlimited money to your account with ease."
            )
        ]
        
        let settings = FastAppSettings(
            appName: "Catagotchi",
            companyName: "01lab",
            companyEmail: "udevwork@email.com",
            revenueCatAPI: "appl_blASkoHVVBInaaYAfQWYtWsSoAc",
            paywallBenefits: benefits,
            onboardingItems: onboarding,
            END_USER_LICENSE_AGREEMENT_URL: "https://principled-crustacean-be6.notion.site/END-USER-LICENSE-AGREEMENT-OverCam-917c34e1ed5b4f9ba040fcfd844ff573?pvs=74",
            PRIVACY_POLICY_LINK: "https://principled-crustacean-be6.notion.site/END-USER-LICENSE-AGREEMENT-OverCam-917c34e1ed5b4f9ba040fcfd844ff573?pvs=74",
            TERMS_CONDITIONS_LINK: "https://principled-crustacean-be6.notion.site/END-USER-LICENSE-AGREEMENT-OverCam-917c34e1ed5b4f9ba040fcfd844ff573?pvs=74"
        )
        
        FastApp.shared.setup(settings)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("Разрешение на уведомления получено")
                self.scheduleDailyNotification()
            } else {
                print("Разрешение на уведомления отклонено")
            }
        }
        
        return true
    }
    
    func scheduleDailyNotification() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            // Проверяем, существует ли уже уведомление на 9:00
            let notificationExists = requests.contains(where: { request in
                guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {
                    return false
                }
                return trigger.dateComponents.hour == 9 && trigger.dateComponents.minute == 0
            })
            
            // Если уведомление на 9:00 уже существует, не создаем новое
            if notificationExists {
                print("Уведомление уже запланировано на 9:00")
                return
            }
            
            // Создаем контент уведомления
            let content = UNMutableNotificationContent()
            content.title = "The cat needs your attention!"
            content.body = "It's time to feed your pet!"
            content.sound = UNNotificationSound.default
            
            // Настраиваем триггер на основе времени (каждый день в 9:00)
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            dateComponents.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // Создаем запрос на уведомление
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            // Добавляем запрос в центр уведомлений
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("Ошибка при создании уведомления: \(error.localizedDescription)")
                } else {
                    print("Уведомление успешно добавлено")
                }
            }
        }
    }

}


@main
struct CatTamagochiApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            GameView()
                .preferredColorScheme(.light)
                .fastAppDefaultWrapper()
        }.onChange(of: scenePhase) { old, newPhase in
            switch newPhase {
                case .background:
                    DateKeeper.saveCurrentDate()
                    print("Приложение ушло в фон. Дата сохранена.")
                case .active:
                    print("Приложение снова активно.", DateKeeper.getSecondsDifference() ?? -1.0)
                case .inactive:
                    print("Приложение неактивно.")
                default:
                    break
            }
        }
    }
}
