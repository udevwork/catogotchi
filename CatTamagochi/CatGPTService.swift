//
//  CatGPTService.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 07.09.2024.
//

import Foundation
import ChatGPTSwift

// Модель ответа от ChatGPT API
//struct CatResponse: Codable {
//    let moodImpact: Double
//    let text: String
//}

// Класс, который будет отвечать за запросы к API
class CatGPTService {
    
    var api: ChatGPTAPI? = nil

    init() {
        if let apiKey = readAPIKey() {
            self.api = ChatGPTAPI(apiKey: apiKey)
        } else {
            fatalError()
        }
    }

    // Запрос для получения случайной мысли кота
    func generateCatThought(parametrs: CatParameters) async throws -> String {
        guard let api = api else { return "" }
        
        let thought = """
        Тебе нужно сгенерировать коротенькую, буквально в 5-9 слов максимум, мысль, которая могла прийти коту. Эта мысль может быть безумна, такая, которая прийдет только коту!
        
        Темы на которые может думать кот: 
        Кошачая философия, мысли о хозяине, кошачьи планы на будущее, кошачьи шутки, рассуждение о кошачей жизни.
        Кошачья мысль, которую ты должен сгенерировать - должна соответствовать настроению кота.
        Текущее настроение кота: \(parametrs[Stat.id("MoodLevel")]) [0 - мысли максимально агрессивные, 100 - мысли максимально добрые]
        """
        
        let needs = """
        
        Проанализируй эти параметры кота:
        \(parametrs.formattedDescription())
        
        Найди парамтр который может волновать кота.
        Ты должен сгенерировать короткую кошачью фразу с потребностью кота.
        Например если голод = 100, значит кот голодный и должен в юмористической форме сообщить об этом игроку/пользователю.
        
        Тебе нужно сгенерировать короткую подсказку в кошачем ситле до 10 слов.
        """
        
        let hint = """
        Выбери ОДНУ тему для подсказки:
        
        "Кота надо кормить и поить, иначе он может умереть."
        "У Кота есть настроеине и нужно уделять внимание."
        "У кота есть много других характеристик о которых только сам кот может рассказать по нажатию."
        "Коту можно покупать новые предметы."
        "Новые предметы открывают новые комманды."
        "Пользователь может вводить разные комманды для игры или кормления кота."
        "Комманд для ввода очень много, их надо исследовать самому."
        "Комманды для ввода открываются при покупке новых предметов."
        "В Магазине много разных пердметов для покупки."
        "Что бы зарабатывать монетки - нужно взаимодействовать с котом."
        
        Тебе нужно сгенерировать короткий текст подсказки в кошачем стиле до 10 слов на ту тему которую ты выбрал.
        Саму тему не пиши, только подсказку.
        Это будет подсказка для игрока в игре.
        """
        
        let lastOwnerActions = """
        Сгенерируй которкую кошачью мысль в одно предложение на тему "Что я думаю о моем хозяне?"
        Вот список последних действий которые хозяин к тебе применял:
        [ \(parametrs.getAlllastOwnerActions()) ]
        Если список пустой - просто расскажи кошачью шутку
        """
        
        let joke = """
        Пошути как бы пошутил кот. до 10 слов.
        """
        
        var promt: String
        if parametrs[Stat.id("EnergyLevel")] > 10 {
            promt = [thought, needs, hint, lastOwnerActions].randomElement() ?? joke
        } else {
            return "low energy..."
        }
        
        api.replaceHistoryList(with: [])
        let stream = try await api.sendMessage(text: promt, systemText: "ты - тамагочи кот в игре.", temperature: 1.0)
        return stream
    }
        
    // Запрос для генерации мысли по введенной команде
    func generateCatThoughtWithCommand(text: String, parametrs: CatParameters, moodLevel: Double) async throws -> String {
        guard let api = api else { return "" }
        let prompt = """
        Тебе нужно сгенерировать короткую, на 6-10 слов максимум, мысль, которая могла прийти коту в голову.
        Мысль обязательно должна быть на тему: "\(text)".

        Текущее настроение кота: \(parametrs[Stat.id("MoodLevel")]) [0 - мысли максимально агрессивные, 100 - мысли максимально добрые]

        Кошачья мысль, которую ты должен сгенерировать - должна соответствовать настроению кота.
        """
        
        if parametrs[Stat.id("EnergyLevel")] < 10 {
            return "low energy..."
        }
        
        api.replaceHistoryList(with: [])
        let stream = try await api.sendMessage(text: prompt, systemText: "ты - тамагочи кот в игре.", temperature: 1.0)
        
        return stream
        
//        let jsonString = extractJSONString(from: stream)
//        if let jsonData = jsonString.data(using: .utf8) {
//            let response = try JSONDecoder().decode(CatResponse.self, from: jsonData)
//            return response
//        } else {
//            throw NSError(domain: "Invalid JSON", code: -1, userInfo: nil)
//        }
    }

    // Функция для извлечения JSON из строки
    private func extractJSONString(from text: String) -> String {
        let startDelimiter = "```json"
        let endDelimiter = "```"
        
        guard let startRange = text.range(of: startDelimiter),
              let endRange = text.range(of: endDelimiter, range: startRange.upperBound..<text.endIndex) else {
            return text
        }
        
        let jsonString = text[startRange.upperBound..<endRange.lowerBound]
        return String(jsonString).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func readAPIKey() -> String? {
        guard let fileURL = Bundle.main.url(forResource: "GPTAPIKey", withExtension: "txt") else {
            print("Файл GPTAPIKey.txt не найден.")
            return nil
        }

        do {
            let apiKey = try String(contentsOf: fileURL, encoding: .utf8)
            return apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("Ошибка при чтении файла: \(error)")
            return nil
        }
    }
    
}
