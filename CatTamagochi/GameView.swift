//
//  ContentView.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 06.09.2024.
//

import SwiftUI
import SwiftData
import FastAppLibrary
import Combine

extension GameViewController {
    
}

class GameViewController: ObservableObject {
    
    @Published var isLoading = false
  
    @Published var inputCommand = ""
    @Published var inputSuggestion: [Command] = [
        Command(commandName: "play", description: "Play with cat"),
        Command(commandName: "hit", description: "Hit the cat")
    ]
    
    @Published var catSayStack: [String] = []
    
    @Published var catText: String = ""
    @Published var catThinkAboutOwnerText: String = ""
    @Published var catBirthDayDiff: TimeInterval = 0.0
    
    @Published var needToCreateCat: Bool = true
    
    // Constants
    let standartErrorText: String = " =( "
    let timeBeforeTextHide = 4.0
    
    var workItem: DispatchWorkItem?
    
    public let apiService = CatGPTService()
    public let animator = Animator()
    public var soundPlayer = SoundPlayerView()
    public lazy var commandsManager: CommandsManager = CommandsManager(gameController: self)
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        
        self.needToCreateCat = DateKeeper.getSavedBirthDate() == nil
        
        self.catBirthDayDiff = DateKeeper.getDaysSinsBirth() ?? 0.0
        
        CatParameters.shared.$parameters
            .sink { newParameters in
                print("Параметры обновлены: \(newParameters)")
                
                if let health = newParameters["HealthLevel"] {
                    if health == 0 {
                        self.animator.setIdle(.dead)
                        CatParameters.shared.setCatDead(true)
                    }
                }
            }
            .store(in: &cancellables)
        
        
        if let secondsSinceLastEnter = DateKeeper.getSecondsDifference() {
            // 20 в релизе должно пойти
            CatParameters.shared[Stat.id("HealthLevel")] -= (secondsSinceLastEnter/5).rounded()
            CatParameters.shared[Stat.id("HungerLevel")] += (secondsSinceLastEnter/5).rounded()
            CatParameters.shared[Stat.id("ThirstLevel")] += (secondsSinceLastEnter/5).rounded() // жажда
            CatParameters.shared[Stat.id("EnergyLevel")] += (secondsSinceLastEnter/5).rounded() // енергия всегда увеличивается со врменем
            CatParameters.shared[Stat.id("CleanlinessLevel")] -= (secondsSinceLastEnter/5).rounded()
            CatParameters.shared[Stat.id("DesireToPlayLevel")] += (secondsSinceLastEnter/5).rounded()
            CatParameters.shared[Stat.id("MoodLevel")] -= (secondsSinceLastEnter/5).rounded()
            CatParameters.shared[Stat.id("SleepinessLevel")] += (secondsSinceLastEnter/5).rounded()
            CatParameters.shared[Stat.id("FriendlinessLevel")] -= (secondsSinceLastEnter/5).rounded()
            CatParameters.shared[Stat.id("FeelingOfSafetyLevel")] -= (secondsSinceLastEnter/5).rounded()
            CatParameters.shared[Stat.id("TrainingLevel")] -= (secondsSinceLastEnter/5).rounded()
            CatParameters.shared[Stat.id("AgilityLevel")] -= (secondsSinceLastEnter/5).rounded() // ловкость
            CatParameters.shared[Stat.id("IntelligenceLevel")] -= (secondsSinceLastEnter/5).rounded()
            CatParameters.shared[Stat.id("HygieneLevel")] -= (secondsSinceLastEnter/5).rounded()
            CatParameters.shared[Stat.id("FearLevel")] += (secondsSinceLastEnter/5).rounded()
            CatParameters.shared[Stat.id("ComfortLevel")] -= (secondsSinceLastEnter/5).rounded()
            CatParameters.shared[Stat.id("NeedForCommunicationLevel")] += (secondsSinceLastEnter/5).rounded()
        }
        
        
    }
    
    // Запрос на получение случайной кошачьей мысли
    func request() {
        
        if isLoading { return }
        isLoading = true
        Haptic.impact()
     
        Task {
            do {
                let gptResponce = try await apiService.generateCatThought(parametrs: CatParameters.shared)
                DispatchQueue.main.async {
                    
                    self.showMessage("[ \(gptResponce) ]")
                    self.animator.play(.talk)
                    self.soundPlayer.playSound(fileName: "tolk-\(Int.random(in: 0..<6))", fileType: "wav")
                    
                }
            } catch {
                print(error)
                self.finishRequest()
            }
        }
    }
    
    // Запрос с использованием команды пользователя
    func request(text: String) {
        Haptic.impact()
        if isLoading { return }
        isLoading = true
        Task {
            do {
                let response = try await apiService.generateCatThoughtWithCommand(text: text, parametrs: CatParameters.shared, moodLevel: CatParameters.shared[Stat.id("MoodLevel")])
                DispatchQueue.main.async {
                    self.showMessage("[ \(response) ]")
                }
            } catch {
                print(error)
                DispatchQueue.main.async {
                    self.showMessage(self.standartErrorText)
                }
            }
        }
    }
    
    // Общая функция для завершения запроса
    private func finishRequest() {
        workItem?.cancel()
        workItem = DispatchWorkItem { [weak self] in
            self?.catSayStack.removeLast()
            if self?.catSayStack.isEmpty ?? false {
                withAnimation(.easeInOut) {
                    self?.catText = ""
                }
                self?.isLoading = false
            } else {
                withAnimation(.easeInOut) {
                    self?.catText = self?.catSayStack.last ?? ""
                }
                self?.finishRequest()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeBeforeTextHide, execute: workItem!)
    }
    
    public func sandCommand() {
        commandsManager.findCommand(name: inputCommand)
        inputCommand = ""
        if inputCommand.isEmpty {
            Haptic.selection()
        }
    }
    
    func findSuggestion() {
        
        let _finded = commandsManager.findCommandSuggestion(name: inputCommand)
        if _finded.isEmpty {
            withAnimation(.bouncy()) {
                inputSuggestion = [
                    Command(commandName: "play", description: "Play with cat"),
                    Command(commandName: "hit", description: "Hit the cat")
                ]
            }
        } else {
            withAnimation(.bouncy()) {
                inputSuggestion = _finded
            }
          
        }
    }
    
    func showMessage(_ txt: String) {
        
        if catSayStack.isEmpty {
            catSayStack.insert(txt, at: 0)
            withAnimation(.easeInOut) {
                catText = txt
            }
        } else {
            catSayStack.insert(txt, at: 0)
        }
        
        finishRequest()
    }
    
    func skipCatText(){
        finishRequest()
    }
    
    func restart() {
        CatParameters.shared.setCatDead(false)
        CatParameters.shared.resetParamers()
        CatParameters.shared.clearitems()
        CatParameters.shared.resetMoney()
        CatParameters.shared.clearlastOwnerActions()
        DateKeeper.deleteBirthdate()
        DateKeeper.deleteLastDate()
        DateKeeper.saveBirthDate()
        animator.setIdle(.idle)
    }
    
    
    func createCat() {
        DateKeeper.saveBirthDate()
        withAnimation {
            self.needToCreateCat = DateKeeper.getSavedBirthDate() == nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.animator.play(.happy)
        })  
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
            self.request(text: "У тебя новый хозяин! поздоровайся!")
        })
      
    }
    
    
}


struct GameView: View {
    
    @StateObject var model = GameViewController()
    @ObservedObject var params = CatParameters.shared
    @State var openMarket = false
    
    @FocusState var inputCommandFocused: Bool
    @State var inputCommandPressed: Bool = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
       
                    ScrollView (.vertical) {
                        VStack(alignment: .leading, spacing: 20, content: {
                        
                            if params.isCatDead == false {
                                HStack {
                                    HStack {
                                        Image("coins")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 25, height: 10)
                                        Text("\(params.money)").bold()
                                        
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal,12)
                                    .padding(.vertical,9)
                                    .background(.accent)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    
                                    HStack {
                                        
                                        Text("\(Int(model.catBirthDayDiff)) years").bold()
                                        
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal,12)
                                    .padding(.vertical,9)
                                    .background(.black)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    Spacer()
                                    
                                }.padding(.horizontal, 16)
                            }
                            
                            ZStack(alignment: .top) {
                                model.animator.videoPlayer
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                                    .listRowSeparator(.hidden)
                                    .onTapGesture {
                                        model.request()
                                    }
                                if model.isLoading {
                                    ProgressView().padding(15)
                                        .transition(.slide)
                                }
                            }.padding(.horizontal, 16)
                            if params.isCatDead == false {
                                if  model.catText.isEmpty == false {
                                    Text(model.catText)
                                        .contentTransition(.numericText())
                                        .padding()
                                        .background(model.catText.isEmpty ? .clear : Color.systemBackground )
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(color: .black.opacity(0.2), radius: 20, x: 10, y: 10)
                                        .padding(.horizontal, 16)
                                        .onTapGesture {
                                            
                                        }
                                }
                                
                                HStack(alignment: .center) {
                                    Spacer()
                                    StatParameterView(progressValue: Int(params[Stat.id("HealthLevel")]), iconName: "heart.fill")
                                    Spacer()
                                    StatParameterView(progressValue: Int(params[Stat.id("EnergyLevel")]), iconName: "bolt.fill")
                                    Spacer()
                                    StatParameterView(progressValue: Int(params[Stat.id("HungerLevel")]), iconName: "fork.knife")
                                    Spacer()
                                }
                                .padding(20)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding(.horizontal, 16)
                                
                                VStack{
                                    ForEach(params.allCases, id: \.0) { key, val in
                                        HStack {
                                            Text(key)
                                            Spacer()
                                            DotsProgressBar(value: Int(val ?? 0))
                                        }
                                    }
                                } .padding(20)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .padding(.horizontal, 16)
                            } else {
                                HStack {
                                    Spacer()
                                    VStack {
                                        Text("Your cat is dead")
                                        Button(action: {
                                            model.restart()
                                        }, label: {
                                            Image(systemName: "arrow.circlepath")
                                            Text("Restart")
                                        }) .foregroundStyle(.white)
                                            .padding(.horizontal,12)
                                            .padding(.vertical,9)
                                            .background(.accent)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                    }
                                    Spacer()
                                }
                            }
                            Rectangle().foregroundStyle(.clear).frame(height: 70)
                            
                        })
                    }
                    .overlay(content: {
                        Rectangle()
                            .foregroundStyle(.white)
                            .opacity(inputCommandPressed ? 0.6 : 0)
                            .onTapGesture {
                                withAnimation {
                                    inputCommandPressed = false
                                }
                            }
                        
                    })
                    .blur(radius: inputCommandPressed ? 15 : 0)
                    if params.isCatDead == false {
                        VStack {
                            if inputCommandPressed == true {
                                ZStack(alignment: .leading) {
                                    VStack(alignment: .leading, spacing: 20) {
                                        TextField(
                                            "Command",
                                            text: $model.inputCommand
                                        )
                                        .focused($inputCommandFocused)
                                        .bold()
                                        .onSubmit {
                                            model.sandCommand()
                                        }
                                        .onChange(of: model.inputCommand, {
                                            model.findSuggestion()
                                        })
                                        .textInputAutocapitalization(.never)
                                        
                                        
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Suggestions:")
                                                .foregroundStyle(.gray)
                                                .font(.footnote)
                                                .bold()
                                            
                                            
                                            ForEach(model.inputSuggestion, id: \.commandName) { cmd in
                                                Button(action: {
                                                    model.inputCommand = cmd.commandName ?? ""
                                                }, label: {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text("> \(cmd.commandName ?? "")")
                                                            .bold()
                                                        Text(cmd.description ?? "")
                                                            .font(.footnote)
                                                           
                                                            .multilineTextAlignment(.leading)
                                                    }
                                                }).foregroundStyle(.black)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color.systemBackground )
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(color: .gray, radius: 20, x: 15, y: 0)
                                    .padding()
                                }.transition(.slide)
                                
                            }
                            Spacer()
                            if inputCommandPressed == false {
                                ZStack(alignment: .leading) {
                                    HStack {
                                        NavigationLink {
                                            SettingsView()
                                        } label: {
                                            HStack {
                                                Image(systemName: "gearshape.fill")
                                                Text("Settings")
                                                
                                            }
                                        }
                                        
                                        .padding()
                                        .background(Color.systemBackground )
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(color: .black.opacity(0.2), radius: 20, x: 10, y: 10)
                                        
                                        HStack {
                                            Image(systemName: "cart.fill")
                                            Text("Market")
                                                .onTapGesture {
                                                    Haptic.selection()
                                                    self.openMarket.toggle()
                                                }
                                        }
                                        .padding()
                                        .background(Color.systemBackground )
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(color: .black.opacity(0.2), radius: 20, x: 10, y: 10)
                                        
                                        HStack {
                                            Image(systemName: "apple.terminal.fill")
                                            Text("Command")
                                                .onTapGesture {
                                                    Haptic.selection()
                                                    withAnimation {
                                                        inputCommandPressed = true
                                                    }
                                                    inputCommandFocused.toggle()
                                                }
                                        }
                                        .padding()
                                        .background(Color.systemBackground )
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(color: .black.opacity(0.2), radius: 20, x: 10, y: 10)
                                        
                                        
                                    }.padding()
                                        .font(.footnote)
                                }
                                
                            }
                        }
                    }
              
            }
            .onChange(of: inputCommandFocused, {
                if inputCommandFocused == false {
                    withAnimation {
                        inputCommandPressed = false
                    }
                }
            })
            .sheet(isPresented: $openMarket, content: {
                CatMarket(gamecontroller: model)
            })
            
            .fullScreenCover(isPresented: $model.needToCreateCat, content: {
                IntroView(model: model)
            })
            .navigationTitle("Catagothci")
            .background(.screenBack)
        } .fontDesign(.monospaced)
        
    }
}

#Preview {
    GameView()
}
