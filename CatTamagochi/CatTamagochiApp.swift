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
            .init(image: "1", title: "Widget on the Watch Face", subTitle: "Quick access to any note directly from \"Always On.\"."),
            .init(image: "2", title: "Notes and Planner", subTitle: "Data is stored locally and in your iCloud. You always have access."),
            .init(image: "3", title: "Synchronization", subTitle: "Connection with your watch does not depend on the internet. Even without your phone, you can still access data on your watch.")
        ]
        
        let benefits: [PaywallBenefitItem] = [
            .init(systemIcon: "wand.and.stars.inverse",
                  title: "Unlimited",
                  subtitle: "Create notes without any limits."),
            .init(systemIcon: "icloud.and.arrow.up.fill",
                  title: "Synchronization",
                  subtitle: "Your notes will sync with all devices."),
            .init(systemIcon: "sparkles.rectangle.stack",
                  title: "Widgets",
                  subtitle: "Access to all types of widgets")
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
        // Создаем контент уведомления
        let content = UNMutableNotificationContent()
        content.title = "The cat needs attention!"
        content.body = "You need to feed your pet!"
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
