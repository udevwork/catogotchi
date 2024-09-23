//
//  ItemsEditor.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 20.09.2024.
//

import SwiftUI
import SwiftyJSON
import FastAppLibrary

enum Relations: String, CaseIterable {
    case more = "more"
    case equal = "equal"
    case less = "less"
    
    func symbol() -> String {
        switch self {
            case .more:
                ">"
            case .equal:
                "="
            case .less:
                "<"
        }
    }
}

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
    
    @Published var animationList: [String] = []
    @Published var soundList: [String] = []
    @Published var items: [MarketItem] = []

    
    init() {
        if let suggestions = loadSuggestionsFromFile() {
            self.suggestion = suggestions
        } else if let suggestions = findCommandSuggestion() {
            self.suggestion = suggestions
        }
        
        if let animations = listMP4Files() {
            animationList = animations
        }
  
        if let sounds = listWAVFiles() {
            soundList = sounds
        }
  
        items = listOfMarketItems()
    }
    
    
    func listOfMarketItems() -> [MarketItem] {
        let path = Bundle.main.path(forResource: "Marketitems", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
        let json = try! JSON(data: data)
        
        do {
            let objData = try json.rawData()
            return try JSONDecoder().decode([MarketItem].self, from: objData)
            
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }
    
    func listMP4Files() -> [String]? {
        // Ищем все файлы с расширением .mp4 в главном Bundle
        if let mp4Files = Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil) {
            // Получаем названия файлов без расширений
            var result = mp4Files.map { $0.deletingPathExtension().lastPathComponent }
            result.append("NaN")
            return result
        }
        return nil
    }
    
    func listWAVFiles() -> [String]? {
        // Ищем все файлы с расширением .mp4 в главном Bundle
        if let wavFiles = Bundle.main.urls(forResourcesWithExtension: "wav", subdirectory: nil) {
            // Получаем названия файлов без расширений
            var result =  wavFiles.map { $0.deletingPathExtension().lastPathComponent }
            result.append("NaN")
            return result
        }
        return nil
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
        let newCommand = CommandModel(commandName: "new_command")
        
        let req = RequirementModel()
        req.parameter = "EnergyLevel"
        req.relation = "more"
        req.value = 0
        newCommand.requirements.append(req)
        
        let inf = InfluenceModel()
        inf.parameter = "EnergyLevel"
        inf.value = -20
        newCommand.influence.append(inf)
        
        suggestion.append(newCommand)
        FastApp.alerts.show(title: "Created new command")
        Haptic.impact()
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
                FastApp.alerts.show(title: "Saved!")
                Haptic.impact()
            }
        } catch let error {
            print("Error saving data: \(error.localizedDescription)")
            FastApp.alerts.show(title: "Save error")
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
                    Section {
                        HStack(alignment:.top) {
                            
                            VStack(alignment: .center, spacing: 5) {
                                Circle().frame(width: 10, height: 10)
                                Rectangle().frame(width: 2).clipShape(RoundedRectangle(cornerRadius: 1))
                            }.foregroundStyle(.gray)
                           
                            
                            
                            VStack(alignment: .leading) {
                                
                                VStack(alignment:.leading, spacing: 20) {
                                    
                                    TextInputView(label: "command name", value: $cmd.commandName).onSubmit {
                                        cmd.commandName = cmd.commandName.replaceSpacesAndTrim()
                                        model.update()
                                    }
                                    TextInputView(label: "description", value: $cmd.description)
                                }
                                .padding()
                                .background(Color.systemGray6)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                
                                Rectangle().frame(height: 30).foregroundStyle(.clear)
                                
                                Text("Requirements:").bold().listRowSeparator(.hidden)
                                
                                ForEach($cmd.requirements, id: \.id) { $req in
                                    HStack(spacing: 0) {
                                        
                                        Menu {
                                            Button("Money", action: {
                                                req.parameter = "Money"
                                                model.update()
                                            })
                                            ForEach(Array(CatParameters.shared.parameters.keys), id: \.self) { param in
                                               
                                                Button(param, action: {
                                                    req.parameter = param
                                                    model.update()
                                                })
                                            }
                                        } label: {
                                            Text("\(req.parameter)")
                                        }.buttonStyle(.bordered)
                                        
                                        Spacer()
                                        
                                        Menu {
                                            ForEach(Relations.allCases, id: \.self) { rele in
                                            
                                                Button(rele.symbol(), action: {
                                                    req.relation = rele.rawValue
                                                    model.update()
                                                })
                                            }
                                           
                                        } label: {
                                            Text(Relations(rawValue: req.relation)?.symbol() ?? "")
                                        }.buttonStyle(.bordered)
                                        
                                        Spacer()
                                        
                                        DoubleInputView(label: "Value", value: $req.value)
                                            .frame(width: 75)
                                        
                                        Spacer()
                                        
                                        Button {
                                            model.removeRequirement(cmd: cmd, req: $req.wrappedValue)
                                        } label: {
                                            Image(systemName: "trash.fill")
                                        }.buttonStyle(.bordered)
                                    }
                                    .padding(5)
                                    .background(Color.systemGray6)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                
                                Button(action: {
                                    cmd.requirements.append(RequirementModel())
                                    model.update()
                                }) {
                                    Text("+ Add Requirement")
                                }.buttonStyle(.bordered)
                          
                                Rectangle().frame(height: 30).foregroundStyle(.clear)
                                
                                
                                Text("Influence:").bold()
                                    .listRowSeparator(.hidden)
                                
                                ForEach($cmd.influence, id: \.id) { $inf in
                                    VStack(alignment:.leading, spacing: 20) {
                                        
                                        HStack {
                                            Menu {
                                                Button("Money", action: {
                                                    inf.parameter = "Money"
                                                    model.update()
                                                })
                                                ForEach(Array(CatParameters.shared.parameters.keys), id: \.self) { param in
                                                    
                                                    Button(param, action: {
                                                        inf.parameter = param
                                                        model.update()
                                                    })
                                                }
                                                
                                            } label: {
                                                Text("\(inf.parameter)").bold()
                                            }.buttonStyle(.bordered)
                                            
                                            Spacer()
                                            DoubleInputView(label: "Value", value: $inf.value)
                                                .frame(width: 75)
                                            
                                        }
                                        
                                        Divider()
                                        
                                        Menu {
                              
                                            ForEach(model.animationList, id: \.self) { anim in
                                            
                                                Button(anim, action: {
                                                    inf.animationName = anim
                                                    if anim == "NaN" {
                                                        inf.animationName = nil
                                                    }
                                                    model.update()
                                                })
                                            }
                                           
                                        } label: {
                                            Text("animation: ").foregroundStyle(.black) + Text(inf.animationName ?? "-").bold()
                                        }
                                        
                                        Menu {
                              
                                            ForEach(model.soundList, id: \.self) { soun in
                                            
                                                Button(soun, action: {
                                                    inf.sound = soun
                                                    if soun == "NaN" {
                                                        inf.sound = nil
                                                    }
                                                    model.update()
                                                })
                                            }
                                           
                                        } label: {
                                            Text("sound: ").foregroundStyle(.black) + Text(inf.sound ?? "-").bold()
                                        }
                                        
                                      
                                      
                                        Button {
                                            model.removeInfluence(cmd: cmd, inf: $inf.wrappedValue)
                                        } label: {
                                            Text("delete")
                                        }.buttonStyle(.bordered)
                                        
                                    }
                                    .padding()
                                        .background(Color.systemGray6)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                
                                Button(action: {
                                    cmd.influence.append(InfluenceModel())
                                    model.update()
                                }) {
                                    Text("+ Add Influence")
                                }.buttonStyle(.bordered)
                                
                                Rectangle().frame(height: 30).foregroundStyle(.clear)

                                
                                Text("Presence:").bold()
                                    .listRowSeparator(.hidden)
                                VStack(alignment: .leading, spacing: 20) {
                                    ForEach($cmd.presence, id: \.self) { prs in
                                        HStack {
                                            TextField("Presence", text: prs)
                                            Spacer()
                                            Button {
                                                model.removePresence(cmd: cmd, pers: prs.wrappedValue)
                                            } label: {
                                                Text("delete")
                                            }.buttonStyle(.bordered)
                                        }
                                    }
                                  
                                    Menu {
                                        ForEach(model.items, id: \.id) { item in
                                            Button(item.itemName ?? "", action: {
                                                if let id = item.id {
                                                    cmd.presence.append(id)
                                                    model.update()
                                                }
                                            })
                                        }
                                    } label: {
                                        Text("+ Add Presence").foregroundStyle(.black)
                                    }
                                    
                                }
                                .padding()
                                .background(Color.systemGray6)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                
                            }
                        }
                    } header: {
                        Text($cmd.commandName.wrappedValue)
                    } footer: {
                        Button {
                            model.removeCommand(cmd: cmd)
                        } label: {
                            Text("delete command")
                        }
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
    NavigationStack {
        ItemsEditor()
            .fontDesign(.monospaced)
    }
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

struct TextInputView: View {
    var label: String // Динамическое название
    
    @Binding var value: String // Для String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label).font(.footnote)
            TextField(label, text: $value)
            Rectangle().frame(height: 1)
        }
    }
}

struct DoubleInputView: View {
    var label: String // Динамическое название
    
    @Binding var value: Double // Для Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label).font(.footnote)
            TextField(label, value: $value, formatter: NumberFormatter())
                .keyboardType(.decimalPad)
         
            Rectangle().frame(height: 1)
        }
    }
}

extension String {
    func replaceSpacesAndTrim() -> String {
        // Обрезаем пробелы по бокам и заменяем оставшиеся пробелы на нижние подчеркивания
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
                   .replacingOccurrences(of: " ", with: "_")
    }
}
