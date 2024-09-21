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
            
            NavigationLink {
                ItemsEditor()
            } label: {
                Text("Item Editor").bold()
            }

            
            Button(action: {
                params.changeMoney(val: 300)
                Haptic.impact(style: .heavy)
            }, label: {
                Text("Add $300").bold()
            })
            
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
            }
            
            Section {
                
                Button(action: {
                    params.clearitems()
                    Haptic.impact(style: .heavy)
                }, label: {
                    Text("Clear items").bold()
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
                Text("Items")
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

         
        }
    }
}

#Preview {
    SettingsView()
}
