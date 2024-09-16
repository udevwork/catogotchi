//
//  CatParametrs.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 07.09.2024.
//

import Foundation

enum Stat {
    case id(String)
}

enum Item {
    case id(String)
}

class CatParameters: ObservableObject {
    
    public static var shared: CatParameters = CatParameters()
    private let userDefaults = UserDefaults.standard
    
    @Published private(set) var isCatDead = false
    @Published private(set) var money: Int = 350
    @Published private(set) var lastOwnerActions: [String] = [
        "Feed",
        "Play",
        "Feed"
    ]
    @Published private(set) var itemOwnership: [String: String] = [:]
    @Published private(set) var parameters: [String: Double] = [
        "HealthLevel": 100,
        "HungerLevel": 50,
        "ThirstLevel": 50,
        "EnergyLevel": 75,
        "CleanlinessLevel": 70,
        "DesireToPlayLevel": 60,
        "MoodLevel": 50,
        "SleepinessLevel": 40,
        "FriendlinessLevel": 65,
        "FeelingOfSafetyLevel": 90,
        "TrainingLevel": 40,
        "AgilityLevel": 80,
        "IntelligenceLevel": 70,
        "HygieneLevel": 100,
        "FearLevel": 30,
        "ComfortLevel": 85,
        "NeedForCommunicationLevel": 55
    ]
    
    private init(){
        load()
    }
    
    subscript(_ stat: Item) -> String? {
        get {
            if case let .id(key) = stat {
               return itemOwnership[key]
            }
            return nil
        }
        set(newValue) {
            if case let .id(key) = stat {
                itemOwnership[key] = newValue
                saveItems()
            } else {
                print("нет такого параметра для изменения")
            }
        }
    }
  
    subscript(_ stat: Stat) -> Double {
        get {
            if case let .id(key) = stat {
               return parameters[key]?.rounded() ?? 0
            }
            return 0.0
        }
        set(newValue) {
            if case let .id(key) = stat {
                let validatedValue = min(max(newValue, 0), 100)
                parameters[key] = validatedValue
                save()
            } else {
                print("нет такого параметра для изменения")
            }
        }
    }
 
    func setCatDead(_ dead: Bool){
        isCatDead = dead
        userDefaults.set(isCatDead, forKey: "isCatDead")
    }
    
    func changeMoney(val: Int) {
        let result = money + val
        money = max(0, result)
        userDefaults.set(money, forKey: "money")
    }
    
    func resetMoney() {
        money = 350
        userDefaults.set(money, forKey: "money")
    }

    
    func appendOwnerAction(_ action: String) {
        if lastOwnerActions.count >= 50 {
            // Удаляем самую старую строку (первый элемент массива)
            lastOwnerActions.removeFirst()
        }
        // Добавляем новую строку в конец массива
        lastOwnerActions.append(action)
        savelastOwnerActions()
    }
    
    func getAlllastOwnerActions() -> String {
        return lastOwnerActions.joined(separator: ", ")
    }
    
    func clearlastOwnerActions() {
        lastOwnerActions = []
        savelastOwnerActions()
    }
    
    private func save() {
        userDefaults.set(parameters, forKey: "petStatus")
        print("Saved parameters")
    }
    
    private func saveItems() {
        userDefaults.set(itemOwnership, forKey: "itemOwnership")
        print("Saved Items")
    }
    
    private func savelastOwnerActions() {
        userDefaults.set(lastOwnerActions, forKey: "lastOwnerActions")
        print("Saved lastOwnerActions")
    }
    
    private func load() {
        if let savedPetStatus = userDefaults.dictionary(forKey: "petStatus") as? [String: Double] {
            parameters = savedPetStatus
            print("Извлеченный словарь: \(savedPetStatus)")
        } else {
            print("Словарь petStatus не найден в UserDefaults.")
        }
        
        if let savedItemOwnership = userDefaults.dictionary(forKey: "itemOwnership") as? [String: String] {
            itemOwnership = savedItemOwnership
            print("Извлеченный словарь: \(savedItemOwnership)")
        } else {
            print("Словарь itemOwnership не найден в UserDefaults.")
        }
        
        if let savedlastOwnerActions = userDefaults.array(forKey: "lastOwnerActions") as? [String] {
            lastOwnerActions = savedlastOwnerActions
            print("Извлеченный словарь: \(lastOwnerActions)")
        } else {
            print("Словарь lastOwnerActions не найден в UserDefaults.")
        }
        
        userDefaults.register(defaults: ["money" : 350])
        money = userDefaults.integer(forKey: "money")
        isCatDead = userDefaults.bool(forKey: "isCatDead")
    }
    
    func clearitems() {
        itemOwnership = [:]
        saveItems()
    }
    
    func deleteItem(key: String){
        itemOwnership.removeValue(forKey: key)
        saveItems()
    }
    
    func deleteOwnerAction(_ action: String){
        if let i = lastOwnerActions.firstIndex(of: action) {
            lastOwnerActions.remove(at: i)
            savelastOwnerActions()
        }
    }
    
    func resetParamers() {
        parameters = [
            "HealthLevel": 100,
            "HungerLevel": 50,
            "ThirstLevel": 50,
            "EnergyLevel": 75,
            "CleanlinessLevel": 70,
            "DesireToPlayLevel": 60,
            "MoodLevel": 50,
            "SleepinessLevel": 40,
            "FriendlinessLevel": 65,
            "FeelingOfSafetyLevel": 90,
            "TrainingLevel": 40,
            "AgilityLevel": 80,
            "IntelligenceLevel": 70,
            "HygieneLevel": 100,
            "FearLevel": 30,
            "ComfortLevel": 85,
            "NeedForCommunicationLevel": 55
        ]
        save()
    }
    
    var allCases: [(String, Double?)] {
        return [
            ("Уровень здоровья", parameters["HealthLevel"]),
            ("Уровень голода", parameters["HungerLevel"]),
            ("Уровень жажды", parameters["ThirstLevel"]),
            ("Уровень энергии", parameters["EnergyLevel"]),
            ("Уровень чистоты", parameters["CleanlinessLevel"]),
            ("Желание играть", parameters["DesireToPlayLevel"]),
            ("Настроение", parameters["MoodLevel"]),
            ("Уровень сонливости", parameters["SleepinessLevel"]),
            ("Дружелюбие", parameters["FriendlinessLevel"]),
            ("Чувство безопасности", parameters["FeelingOfSafetyLevel"]),
            ("Уровень тренировки", parameters["TrainingLevel"]),
            ("Ловкость", parameters["AgilityLevel"]),
            ("Интеллект", parameters["IntelligenceLevel"]),
            ("Уровень гигиены", parameters["HygieneLevel"]),
            ("Уровень страха", parameters["FearLevel"]),
            ("Потребность в общении", parameters["NeedForCommunicationLevel"])
        ]
    }
}

extension CatParameters {
    func formattedDescription() -> String {
        return """
          Уровень здоровья - \(parameters["HealthLevel"] ?? 0)
          Уровень голода - \(parameters["HungerLevel"] ?? 0)
          Уровень жажды - \(parameters["ThirstLevel"] ?? 0)
          Уровень энергии - \(parameters["EnergyLevel"] ?? 0)
          Уровень чистоты - \(parameters["CleanlinessLevel"] ?? 0)
          Желание играть - \(parameters["DesireToPlayLevel"] ?? 0)
          Настроение - \(parameters["MoodLevel"] ?? 0)
          Уровень сонливости - \(parameters["SleepinessLevel"] ?? 0)
          Дружелюбие - \(parameters["FriendlinessLevel"] ?? 0)
          Чувство безопасности - \(parameters["FeelingOfSafetyLevel"] ?? 0)
          Уровень тренировки - \(parameters["TrainingLevel"] ?? 0)
          Ловкость - \(parameters["AgilityLevel"] ?? 0)
          Интеллект - \(parameters["IntelligenceLevel"] ?? 0)
          Уровень гигиены - \(parameters["HygieneLevel"] ?? 0)
          Уровень страха - \(parameters["FearLevel"] ?? 0)
          Потребность в общении - \(parameters["NeedForCommunicationLevel"] ?? 0)
          """
    }
}
