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
            ("Health Level", parameters["HealthLevel"]),
            ("Hunger Level", parameters["HungerLevel"]),
            ("Thirst Level", parameters["ThirstLevel"]),
            ("Energy Level", parameters["EnergyLevel"]),
            ("Cleanliness Level", parameters["CleanlinessLevel"]),
            ("Desire to Play", parameters["DesireToPlayLevel"]),
            ("Mood", parameters["MoodLevel"]),
            ("Friendliness", parameters["FriendlinessLevel"]),
            ("Feeling of Safety", parameters["FeelingOfSafetyLevel"]),
            ("Training Level", parameters["TrainingLevel"]),
            ("Agility", parameters["AgilityLevel"]),
            ("Intelligence", parameters["IntelligenceLevel"]),
            ("Hygiene Level", parameters["HygieneLevel"]),
            ("Fear Level", parameters["FearLevel"]),
            ("Need for Communication", parameters["NeedForCommunicationLevel"])
        ]
    }
}

extension CatParameters {
    func formattedDescription() -> String {
        return """
          Health Level - \(parameters["HealthLevel"] ?? 0)
          Hunger Level - \(parameters["HungerLevel"] ?? 0)
          Thirst Level - \(parameters["ThirstLevel"] ?? 0)
          Energy Level - \(parameters["EnergyLevel"] ?? 0)
          Cleanliness Level - \(parameters["CleanlinessLevel"] ?? 0)
          Desire to Play - \(parameters["DesireToPlayLevel"] ?? 0)
          Mood - \(parameters["MoodLevel"] ?? 0)
          Friendliness - \(parameters["FriendlinessLevel"] ?? 0)
          Feeling of Safety - \(parameters["FeelingOfSafetyLevel"] ?? 0)
          Training Level - \(parameters["TrainingLevel"] ?? 0)
          Agility - \(parameters["AgilityLevel"] ?? 0)
          Intelligence - \(parameters["IntelligenceLevel"] ?? 0)
          Hygiene Level - \(parameters["HygieneLevel"] ?? 0)
          Fear Level - \(parameters["FearLevel"] ?? 0)
          Need for Communication - \(parameters["NeedForCommunicationLevel"] ?? 0)
          """
    }
}
