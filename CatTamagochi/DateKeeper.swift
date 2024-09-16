//
//  DateKeeper.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 13.09.2024.
//

import Foundation

class DateKeeper {
    static private let savedDateKey = "savedDateKey"
    static private let savedBirthDateKey = "savedBirthDateKey"
    
    // Функция для сохранения текущей даты в UserDefaults
    static func saveCurrentDate() {
        let currentDate = Date()
        UserDefaults.standard.set(currentDate, forKey: savedDateKey)
        print("Дата сохранена: \(currentDate)")
    }
    
    // Функция для получения сохраненной даты
    static func getSavedDate() -> Date? {
        if let savedDate = UserDefaults.standard.object(forKey: savedDateKey) as? Date {
            return savedDate
        } else {
            print("Дата не была сохранена ранее.")
            return nil
        }
    }
    
    // Функция для получения разницы в секундах между сохраненной датой и текущей
    static func getSecondsDifference() -> TimeInterval? {
        guard let savedDate = getSavedDate() else {
            return nil
        }
        
        let currentDate = Date()
        let difference = currentDate.timeIntervalSince(savedDate) // Разница в секундах
        return difference
    }
    
    
    /// Кошачьи года
    ///
    
    // Функция для сохранения текущей даты в UserDefaults
    static func saveBirthDate() {
        let currentDate = Date()
        UserDefaults.standard.set(currentDate, forKey: savedBirthDateKey)
        print("Дата сохранена: \(currentDate)")
    }
    
    // Функция для получения сохраненной даты
    static func getSavedBirthDate() -> Date? {
        if let savedDate = UserDefaults.standard.object(forKey: savedBirthDateKey) as? Date {
            return savedDate
        } else {
            print("Дата рождения не была сохранена ранее.")
            return nil
        }
    }
    
    // Функция для получения разницы в днях между сохраненной датой и текущей
    static func getDaysSinsBirth() -> TimeInterval? {
        guard let savedDate = getSavedBirthDate() else {
            return nil
        }
        
        let currentDate = Date()
        let difference = currentDate.timeIntervalSince(savedDate)/86400
        return difference
    }
    
    // delete and reset
    
    static func deleteLastDate(){
        UserDefaults.standard.removeObject(forKey: savedDateKey)
    }
    
    static func deleteBirthdate(){
        UserDefaults.standard.removeObject(forKey: savedBirthDateKey)
    }
    
}
