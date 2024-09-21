//
//  ItemsEditor.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 20.09.2024.
//

import SwiftUI
import SwiftyJSON
import FastAppLibrary


// MARK: - Command
class CommandModel: Codable, Identifiable {
    
    init(commandName: String) {
        self.commandName = commandName
        self.description = "description"
        self.requirements = []
        self.influence = []
        self.presence = []
    }
    
    var id = UUID()
    @Published var commandName: String
    @Published var description: String
    @Published var requirements: [RequirementModel] = []
    @Published var influence: [InfluenceModel] = []
    @Published var presence: [String]
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case commandName
        case description
        case requirements
        case influence
        case presence
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.commandName = try container.decode(String.self, forKey: .commandName)
        self.description = try container.decode(String.self, forKey: .description)
        self.requirements = try container.decode([RequirementModel].self, forKey: .requirements)
        self.influence = try container.decode([InfluenceModel].self, forKey: .influence)
        self.presence = try container.decode([String].self, forKey: .presence)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(commandName, forKey: .commandName)
        try container.encode(description, forKey: .description)
        try container.encode(requirements, forKey: .requirements)
        try container.encode(influence, forKey: .influence)
        try container.encode(presence, forKey: .presence)
    }
    
}

// MARK: - Influence
class InfluenceModel: Codable, Identifiable {
    var id = UUID()
    @Published var parameter: String
    @Published var value: Double
    @Published var animationName: String?
    @Published var sound: String?
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case parameter
        case value
        case animationName
        case sound
    }
    
    init() {
        self.parameter = ""
        self.value = 0.0
        self.animationName = ""
        self.sound = ""
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.parameter = try container.decode(String.self, forKey: .parameter)
        self.value = try container.decode(Double.self, forKey: .value)
        self.animationName = try? container.decode(String?.self, forKey: .animationName)
        self.sound = try? container.decode(String?.self, forKey: .sound)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(parameter, forKey: .parameter)
        try container.encode(value, forKey: .value)
        try container.encode(animationName, forKey: .animationName)
        try container.encode(sound, forKey: .sound)
    }
}

// MARK: - Requirement
class RequirementModel: Codable, Identifiable {
    var id = UUID()
    @Published var parameter: String
    @Published var relation: String
    @Published var value: Double
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case parameter
        case relation
        case value
    }
    
    init() {
        self.parameter = ""
        self.relation = ""
        self.value = 0.0
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.parameter = try container.decode(String.self, forKey: .parameter)
        self.relation = try container.decode(String.self, forKey: .relation)
        self.value = try container.decode(Double.self, forKey: .value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(parameter, forKey: .parameter)
        try container.encode(relation, forKey: .relation)
        try container.encode(value, forKey: .value)
    }
}

class ItemsEditorModel: ObservableObject {
    
    @Published var suggestion: [CommandModel] = []
    
    init() {
        if let suggestions = loadSuggestionsFromFile() {
            self.suggestion = suggestions
        } else if let suggestions = findCommandSuggestion() {
            self.suggestion = suggestions
        }
    }
    
    func findCommandSuggestion() -> [CommandModel]? {
        
        let path = Bundle.main.path(forResource: "Commands", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
        let json = try! JSON(data: data)
        do {
            let objData = try json.rawData()
            
            return try JSONDecoder().decode([CommandModel].self, from: objData)
        } catch let error {
            print("Error:", error)
            return nil
        }
    }
    
    func addCommand() {
        let newCommand = CommandModel(commandName: "new")
        suggestion.append(newCommand)
    }
    
    func removeCommand(cmd: CommandModel) {
        let cmdIndexToDelete = self.suggestion.firstIndex {
            cmd.id == $0.id
        }
        guard let cmdIndexToDelete = cmdIndexToDelete else { return }
        self.suggestion.remove(at: cmdIndexToDelete)
        self.update()
    }
    
    func removeRequirement(cmd: CommandModel, req: RequirementModel) {
        let cmdIndex = self.suggestion.firstIndex {
            cmd.id == $0.id
        }
        guard let cmdIndex = cmdIndex else { return }
        
        let reqIndexToDelete = self.suggestion[cmdIndex].requirements.firstIndex {
            req.id == $0.id
        }
        guard let reqIndexToDelete = reqIndexToDelete else { return }
        
        self.suggestion[cmdIndex].requirements.remove(at: reqIndexToDelete)
        self.update()
    }
    
    func removeInfluence(cmd: CommandModel, inf: InfluenceModel) {
        let cmdIndex = self.suggestion.firstIndex {
            cmd.id == $0.id
        }
        guard let cmdIndex = cmdIndex else { return }
        
        let infIndexToDelete = self.suggestion[cmdIndex].influence.firstIndex {
            inf.id == $0.id
        }
        guard let infIndexToDelete = infIndexToDelete else { return }
        
        self.suggestion[cmdIndex].influence.remove(at: infIndexToDelete)
        self.update()
    }
    
    func removePresence(cmd: CommandModel, pers: String) {
        let cmdIndex = self.suggestion.firstIndex {
            cmd.id == $0.id
        }
        guard let cmdIndex = cmdIndex else { return }
        
        let persIndexToDelete = self.suggestion[cmdIndex].presence.firstIndex {
            pers == $0
        }
        guard let persIndexToDelete = persIndexToDelete else { return }
        
        self.suggestion[cmdIndex].presence.remove(at: persIndexToDelete)
        self.update()
    }
    
    func saveSuggestionsToFile() {
        do {
            // Преобразование suggestion в JSON данные
            let jsonData = try JSONEncoder().encode(suggestion)
            
            // Получение пути к документам пользователя
            if let filePath = getDocumentsDirectory()?.appendingPathComponent("Commands.json") {
                // Сохранение данных в файл
                try jsonData.write(to: filePath)
                print("Data saved to \(filePath)")
            }
        } catch let error {
            print("Error saving data: \(error.localizedDescription)")
        }
    }
    
    // Функция для чтения данных из файла и декодирования их из JSON
    func loadSuggestionsFromFile() -> [CommandModel]? {
        do {
            // Получение пути к документам пользователя
            if let filePath = getDocumentsDirectory()?.appendingPathComponent("Commands.json") {
                // Чтение данных из файла
                let data = try Data(contentsOf: filePath)
                
                // Преобразование JSON данных обратно в массив строк (или любую другую нужную вам структуру)
                let suggestions = try JSONDecoder().decode([CommandModel].self, from: data)
                
                // Возвращение прочитанных данных
                return suggestions
            }
        } catch let error {
            print("Error loading data: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    // Функция для получения директории документов пользователя
    func getDocumentsDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    func shareFile() {
       
            // Проверяем, что файл существует по указанному URL
            guard let fileURL = getDocumentsDirectory()?.appendingPathComponent("Commands.json"),
            FileManager.default.fileExists(atPath: fileURL.path) else {
                print("File does not exist at path ")
                return
            }
            
            let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            
            // Находим текущее активное окно и отображаем UIActivityViewController
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityViewController, animated: true, completion: nil)
            }
        }
    
    func update() {
        objectWillChange.send()
    }
    
}

struct ItemsEditor: View {
    @StateObject var model = ItemsEditorModel()
    
    var body: some View {
        ZStack(alignment:.bottom) {
            List {
                ForEach($model.suggestion, id: \.id) { $cmd in
                    Section(header: Text($cmd.commandName.wrappedValue)) {
                        
                        FloatingTextField(text: $cmd.commandName, placehopder: "command name")
                        FloatingTextField(text: $cmd.description, placehopder: "description")
                        
                        Button {
                            model.removeCommand(cmd: cmd)
                        } label: {
                            Text("delete cmd")
                        }.buttonStyle(.bordered)

                        
                        Text("Requirements:").bold().listRowSeparator(.hidden)
                        
                        ForEach($cmd.requirements, id: \.id) { req in
                            VStack(alignment:.leading) {
                                FloatingTextField(text: req.parameter, placehopder: "parameter")
                                FloatingTextField(text: req.relation, placehopder: "relation")
                                TextField("Value", value: req.value, formatter: NumberFormatter())
                                    .padding()
                                    .background(Color.systemGray6)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                Button {
                                    model.removeRequirement(cmd: cmd, req: req.wrappedValue)
                                } label: {
                                    Text("delete requirement")
                                }.buttonStyle(.bordered)
                            }
                        }
                        
                    
                        
                        Button(action: {
                            cmd.requirements.append(RequirementModel())
                            model.update()
                        }) {
                            Text("Add Requirement")
                        } .listRowSeparator(.hidden)
                        
                        Text("Influence:").bold()
                            .listRowSeparator(.hidden)
                        
                        ForEach($cmd.influence, id: \.id) { inf in
                            VStack(alignment:.leading) {
                                FloatingTextField(text: inf.parameter, placehopder: "Parameter")
                                FloatingTextField(text: inf.animationName.bound, placehopder: "Animation")
                                FloatingTextField(text: inf.sound.bound, placehopder: "Sound")
                                TextField("Value", value: inf.value, formatter: NumberFormatter())
                                    .padding()
                                    .background(Color.systemGray6)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                Button {
                                    model.removeInfluence(cmd: cmd, inf: inf.wrappedValue)
                                } label: {
                                    Text("delete influence")
                                }.buttonStyle(.bordered)
                                
                            }
                        }
                        
                     
                        Button(action: {
                            cmd.influence.append(InfluenceModel())
                            model.update()
                        }) {
                            Text("Add Influence")
                        }
                        
                        Text("Presence:").bold()
                            .listRowSeparator(.hidden)
                        ForEach($cmd.presence, id: \.self) { prs in
                            TextField("Presence", text: prs)
                            Button {
                                model.removePresence(cmd: cmd, pers: prs.wrappedValue)
                            } label: {
                                Text("delete presence")
                            }.buttonStyle(.bordered)
                        }
                        Button(action: {
                            cmd.presence.append("")
                            model.update()
                        }) {
                            Text("Add Presence")
                        } .listRowSeparator(.hidden)
                    }
                    
                }

                Rectangle().frame(height: 100).foregroundStyle(.clear)
            }.listStyle(.plain)
                .listSectionSpacing(70)
                .listSectionSeparator(.hidden)
            
            HStack {
                Button(action: model.addCommand) {
                    Text("Create Command")
                }
                Spacer()
                Button(action: model.saveSuggestionsToFile) {
                    Text("Save")
                }
                Spacer()
                Button(action: model.shareFile) {
                    Text("Share")
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    ItemsEditor().fontDesign(.monospaced)
}

extension Binding where Value == String? {
    var bound: Binding<String> {
        Binding<String>(
            get: { self.wrappedValue ?? "" },
            set: { self.wrappedValue = $0 }
        )
    }
}

extension Binding where Value == Double? {
    var bound: Binding<Double> {
        Binding<Double>(
            get: { self.wrappedValue ?? 0.0 },
            set: { self.wrappedValue = $0 }
        )
    }
}
