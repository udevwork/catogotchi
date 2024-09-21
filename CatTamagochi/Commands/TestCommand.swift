//
//  TestCommand.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 07.09.2024.
//

import Foundation
import SwiftyJSON

class CommandsManager {
    
    var json: JSON!
    let gameController: GameViewController
    
    init(gameController: GameViewController) {
        
        self.gameController = gameController
        
        load()
    }
    
    func load() {
        do {
            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            if let filePath = dir?.appendingPathComponent("Commands.json") {
                let data = try Data(contentsOf: filePath)
                json = try JSON(data: data)
            } else {
                let path = Bundle.main.path(forResource: "Commands", ofType: "json")
                let data = try Data(contentsOf: URL(fileURLWithPath: path!))
                json = try JSON(data: data)
            }
        } catch {
            let path = Bundle.main.path(forResource: "Commands", ofType: "json")
            let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
            json = try! JSON(data: data)
        }
    }
    
    // Функция для чтения кастомных данных из файла и декодирования их из JSON
    func loadSuggestionsFromFile() -> [Command]? {
        do {
            // Получение пути к документам пользователя
            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            if let filePath = dir?.appendingPathComponent("Commands.json") {
                // Чтение данных из файла
                let data = try Data(contentsOf: filePath)
                
                // Преобразование JSON данных обратно в массив строк (или любую другую нужную вам структуру)
                let suggestions = try JSONDecoder().decode([Command].self, from: data)
                
                // Возвращение прочитанных данных
                return suggestions
            }
        } catch let error {
            print("Error loading data: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func findCommandSuggestion(name: String) -> [Command] {
        var suggestion: [Command] = []
        for (_, subJson):(String, JSON) in json {
            if subJson["commandName"].stringValue.contains(name) {
                do {
                    let objData = try subJson.rawData()
                    var cmd = try JSONDecoder().decode(Command.self, from: objData)
                    
                    // генерируем в описании подсказку с влиянием
                    var influencesDescription: String = ""
        
                        cmd.influence.forEach {
                            if let parameter = $0.parameter, let value = $0.value {
                                influencesDescription +=  "\n\(parameter): \(value)"
                            }
                        }
                    
                    cmd.description? += influencesDescription
                    suggestion.append(cmd)
                    // Проверяем, достиг ли массив 5 элементов
                    if suggestion.count >= 5 {
                        break
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        return suggestion
    }
    
    func findCommand(name: String) {
        
        let finded = json.first { (str, json) in
            return json["commandName"].stringValue == name
        }
        
        do {
            if let objData = try finded?.1.rawData() {
                let cmd = try JSONDecoder().decode(Command.self, from: objData)
                executeCommand(cmd: cmd)
                
            } else {
                print("Command not found!")
                gameController.showMessage("> The command was not found")
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    
    
    private func executeCommand(cmd: Command) {
        
        print("try execute Command:", cmd.commandName ?? "shit... command dont have name! wtf?!")
        
        
        // Наличие предмета
        var allItemsIsPresence: Bool = true
        
        for itemID in cmd.presence {
            allItemsIsPresence = CatParameters.shared.itemOwnership[itemID] != nil
            if allItemsIsPresence == false {
                break
            }
        }
        
        
        if allItemsIsPresence == false {
            print("Нет нужного предмета для выполнения команды")
            gameController.showMessage("> There is no necessary item to execute this command")
            return
        }
        
        
        // Требования к исполению команды
        var requirementsMet: Bool = true
        var requirementsErrorReason: String = ""
      
        for req in cmd.requirements {
                if let parameter = req.parameter, let value = req.value, let relation = req.relation {
                    requirementsErrorReason = "\(parameter) mast be \(relation) than \(value)"
                    let valToCheck = CatParameters.shared[Stat.id(parameter)]
                    if relation == "more" {
                        requirementsMet = valToCheck > value
                    }
                    if relation == "less" {
                        requirementsMet = valToCheck < value
                    }
                    if relation == "equal" {
                        requirementsMet = valToCheck == value
                    }
                    if requirementsMet == false {
                        break
                    }
                }
            }
        
        
        if requirementsMet == false {
            print("Не соблюдены требования для исполнения команды")
            gameController.showMessage("> The cat's parameters do not allow this command to be executed")
            gameController.showMessage("> \(requirementsErrorReason)")
            return
        }
        
        
        
        // Влияние

        cmd.influence.forEach {
                
                if let animation = $0.animationName {
                    gameController.animator.play(Animator.CatAnimations(rawValue: animation) ?? .idle)
                }
                
                if let parameter = $0.parameter, let value = $0.value {
                    switch parameter {
                        case "Money":
                            CatParameters.shared.changeMoney(val: Int(value))
                        default:
                            CatParameters.shared[Stat.id(parameter)] += value
                    }
                    
                    if value > 0 {
                        gameController.showMessage("> \(parameter) +\(value)")
                    } else {
                        gameController.showMessage("> \(parameter) \(value)")
                    }
                }
            }
        
        
        // GPT запрос
        if let descr = cmd.description {
            gameController.request(text: descr)
        }
        
        // Сохранить в памяти кота это действие
        if let action = cmd.description {
            CatParameters.shared.appendOwnerAction(action)
            print("Действие сохранено в памяти кота")
        }
    }
}

// MARK: - Command
struct Command: Codable, Hashable {
    var commandName: String?
    var description: String?
    var requirements: [Requirement] = []
    var influence: [Influence] = []
    var presence: [String]
    
    init(commandName: String? = nil, description: String? = nil, requirements: [Requirement]? = nil, influence: [Influence]? = nil, presence: [String]? = nil) {
        self.commandName = commandName
        self.description = description
        self.requirements = requirements ?? []
        self.influence = influence ?? []
        self.presence = presence ?? []
    }

}

// MARK: - Influence
struct Influence: Codable, Hashable {
    var parameter: String?
    var value: Double?
    var animationName: String?
    var sound: String?
}

// MARK: - Requirement
struct Requirement: Codable, Hashable {
    var parameter: String?
    var relation: String?
    var value: Double?
}

struct ExecutableCommand {
    let keyPath: WritableKeyPath<CatParameters, Int>
    let changeValue: Int

    init(keyPath: WritableKeyPath<CatParameters, Int>, changeValue: Int) {
        self.keyPath = keyPath
        self.changeValue = changeValue
    }

    func run(catParameters: inout CatParameters) {
        catParameters[keyPath: keyPath] = changeValue
    }
    
    func run(catParameters: inout GameViewController) {
        //catParameters.parametrs[keyPath: keyPath] = changeValue
        catParameters.request(text: "")
    }
}

//
//let commandsBD : [String: ()->() ] = [
//   
//]

// ExecutableCommand(keyPath: \.MoodLevel, changeValue: 30)
