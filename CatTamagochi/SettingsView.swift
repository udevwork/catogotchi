//
//  SettingsView.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 15.09.2024.
//

import SwiftUI
import FastAppLibrary

struct SettingsView: View {
    
    @ObservedObject var params = CatParameters.shared
    
    var body: some View {
        List {
            
            Section {
                Link("Messenger", destination: URL(string: "https://t.me/imbalanceFighter")!)
                    .foregroundStyle(Color.primary)
            } header: {
                Label("Write to me if you have any questions or problems", systemImage: "envelope.badge.fill")
            } footer: {
                Text("I am waiting for your suggestions and comments")
            }
            
            
            Section {
                NavigationLink {
                    ItemsEditor()
                } label: {
                    Text("Console Editor").bold()
                }
            } header: {
                Label("Add new commands to the console or modify existing ones.", systemImage: "apple.terminal.fill")
            } footer: {
                Text("You can even share your custom commands with us, and they might appear in future updates.")
            }
            
            
            Section {
                
                Button(action: {
                    params.changeMoney(val: 300)
                    Haptic.impact(style: .heavy)
                }, label: {
                    Text("Add $300").bold()
                })
            } header: {
                Label("Add money", systemImage: "banknote.fill")
            } footer: {
               
            }
            
            
            Section {
                ForEach(Array(params.lastOwnerActions), id: \.self) { key in
                    HStack {
                        Text(key)
                        Spacer()
                        
                        Button(action: {
                            params.deleteOwnerAction(key)
                        }, label: {
                            Text("delete")
                        }).buttonStyle(BorderedButtonStyle())
                    }
                }
            } header: {
                Label("Modify your pet’s memory.", systemImage: "externaldrive.fill.badge.timemachine")
            } footer: {
                Text("If you want it to forget something unpleasant, just delete it.")
            }
            
           
            
            Section {
                
                Button(action: {
                    params.clearitems()
                    Haptic.impact(style: .heavy)
                }, label: {
                    Text("Clear all items").bold()
                })
                
                ForEach(Array(params.itemOwnership.keys), id: \.self) { key in
                    if let item = params[Item.id(key)] {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("ID: ").foregroundStyle(.gray) + Text(key)
                                Text(item).font(.footnote)
                                
                            }
                            Spacer()
                            HStack {
                                Button(action: {
                                    params.deleteItem(key: key)
                                }, label: {
                                    Text("delete")
                                })
                               
                            }.buttonStyle(BorderedButtonStyle())
                        }
                    }
                }
                
            } header: {
                Text("Edit the items you've purchased")
            }

            
            Section {
                Button(action: {
                    CatParameters.shared.resetParamers()
                    Haptic.impact(style: .heavy)
                }, label: {
                    Text("Reset all paramers").bold()
                })
                
                HStack {
                       Text("HealthLevel \(Int(params[Stat.id("HealthLevel")]))")
                       Spacer()
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("HealthLevel")] += 1
                       }, label: {
                           Text("+")
                       })
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("HealthLevel")] -= 1
                       }, label: {
                           Text("-")
                       })
                   }.buttonStyle(BorderedButtonStyle())

                   HStack {
                       Text("HungerLevel \(Int(params[Stat.id("HungerLevel")]))")
                       Spacer()
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("HungerLevel")] += 1
                       }, label: {
                           Text("+")
                       })
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("HungerLevel")] -= 1
                       }, label: {
                           Text("-")
                       })
                   }.buttonStyle(BorderedButtonStyle())

                   HStack {
                       Text("ThirstLevel \(Int(params[Stat.id("ThirstLevel")]))")
                       Spacer()
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("ThirstLevel")] += 1
                       }, label: {
                           Text("+")
                       })
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("ThirstLevel")] -= 1
                       }, label: {
                           Text("-")
                       })
                   }.buttonStyle(BorderedButtonStyle())

                   HStack {
                       Text("EnergyLevel \(Int(params[Stat.id("EnergyLevel")]))")
                       Spacer()
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("EnergyLevel")] += 1
                       }, label: {
                           Text("+")
                       })
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("EnergyLevel")] -= 1
                       }, label: {
                           Text("-")
                       })
                   }.buttonStyle(BorderedButtonStyle())

                   HStack {
                       Text("CleanlinessLevel \(Int(params[Stat.id("CleanlinessLevel")]))")
                       Spacer()
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("CleanlinessLevel")] += 1
                       }, label: {
                           Text("+")
                       })
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("CleanlinessLevel")] -= 1
                       }, label: {
                           Text("-")
                       })
                   }.buttonStyle(BorderedButtonStyle())

                   HStack {
                       Text("DesireToPlayLevel \(Int(params[Stat.id("DesireToPlayLevel")]))")
                       Spacer()
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("DesireToPlayLevel")] += 1
                       }, label: {
                           Text("+")
                       })
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("DesireToPlayLevel")] -= 1
                       }, label: {
                           Text("-")
                       })
                   }.buttonStyle(BorderedButtonStyle())

                   HStack {
                       Text("MoodLevel \(Int(params[Stat.id("MoodLevel")]))")
                       Spacer()
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("MoodLevel")] += 1
                       }, label: {
                           Text("+")
                       })
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("MoodLevel")] -= 1
                       }, label: {
                           Text("-")
                       })
                   }.buttonStyle(BorderedButtonStyle())

                   HStack {
                       Text("FriendlinessLevel \(Int(params[Stat.id("FriendlinessLevel")]))")
                       Spacer()
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("FriendlinessLevel")] += 1
                       }, label: {
                           Text("+")
                       })
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("FriendlinessLevel")] -= 1
                       }, label: {
                           Text("-")
                       })
                   }.buttonStyle(BorderedButtonStyle())

                   HStack {
                       Text("FeelingOfSafetyLevel \(Int(params[Stat.id("FeelingOfSafetyLevel")]))")
                       Spacer()
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("FeelingOfSafetyLevel")] += 1
                       }, label: {
                           Text("+")
                       })
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("FeelingOfSafetyLevel")] -= 1
                       }, label: {
                           Text("-")
                       })
                   }.buttonStyle(BorderedButtonStyle())

                   HStack {
                       Text("TrainingLevel \(Int(params[Stat.id("TrainingLevel")]))")
                       Spacer()
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("TrainingLevel")] += 1
                       }, label: {
                           Text("+")
                       })
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("TrainingLevel")] -= 1
                       }, label: {
                           Text("-")
                       })
                   }.buttonStyle(BorderedButtonStyle())

                   HStack {
                       Text("AgilityLevel \(Int(params[Stat.id("AgilityLevel")]))")
                       Spacer()
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("AgilityLevel")] += 1
                       }, label: {
                           Text("+")
                       })
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("AgilityLevel")] -= 1
                       }, label: {
                           Text("-")
                       })
                   }.buttonStyle(BorderedButtonStyle())

                   HStack {
                       Text("IntelligenceLevel \(Int(params[Stat.id("IntelligenceLevel")]))")
                       Spacer()
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("IntelligenceLevel")] += 1
                       }, label: {
                           Text("+")
                       })
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("IntelligenceLevel")] -= 1
                       }, label: {
                           Text("-")
                       })
                   }.buttonStyle(BorderedButtonStyle())

                   HStack {
                       Text("HygieneLevel \(Int(params[Stat.id("HygieneLevel")]))")
                       Spacer()
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("HygieneLevel")] += 1
                       }, label: {
                           Text("+")
                       })
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("HygieneLevel")] -= 1
                       }, label: {
                           Text("-")
                       })
                   }.buttonStyle(BorderedButtonStyle())

                   HStack {
                       Text("FearLevel \(Int(params[Stat.id("FearLevel")]))")
                       Spacer()
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("FearLevel")] += 1
                       }, label: {
                           Text("+")
                       })
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("FearLevel")] -= 1
                       }, label: {
                           Text("-")
                       })
                   }.buttonStyle(BorderedButtonStyle())

                   HStack {
                       Text("ComfortLevel \(Int(params[Stat.id("ComfortLevel")]))")
                       Spacer()
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("ComfortLevel")] += 1
                       }, label: {
                           Text("+")
                       })
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("ComfortLevel")] -= 1
                       }, label: {
                           Text("-")
                       })
                   }.buttonStyle(BorderedButtonStyle())

                   HStack {
                       Text("NeedForCommunicationLevel \(Int(params[Stat.id("NeedForCommunicationLevel")]))")
                       Spacer()
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("NeedForCommunicationLevel")] += 1
                       }, label: {
                           Text("+")
                       })
                       Button(action: {
                           Haptic.impact(style: .heavy)
                           params[Stat.id("NeedForCommunicationLevel")] -= 1
                       }, label: {
                           Text("-")
                       })
                   }.buttonStyle(BorderedButtonStyle())
            } header: {
                Text("Parametrs")
            }

         
        }.toolbar {
            Text("Editor v1.1").font(.footnote)
        }
    }
}

#Preview {
    SettingsView()
}
