//
//  IntroView.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 16.09.2024.
//

import SwiftUI
import FastAppLibrary

struct IntroView: View {
    
    @StateObject var model : GameViewController
    @State var loading: Bool = false
    @State var buttonText: String = "Proceed"
    
    func startFakeLoading() {
        withAnimation {
            loading = true
            buttonText = "Proceedings..."
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            model.createCat()
        })
        
    }
    
    var body: some View {
        HStack(alignment: .top) {
            LoopPlayerView(view: LoopingPlayerUIView("loading", width: "mp4", gravity: .resizeAspectFill)!)
                .frame(width: 90)
                .clipShape(RoundedRectangle(cornerRadius: 25.0))
               
            
            HStack {
                Spacer()
                VStack(alignment:.leading, spacing: 26) {
                    Spacer()
                    Text("Create your AI Cat instance")
                        .font(.title)
                        .bold()
                    
                    VStack(alignment:. leading, spacing: 5) {
                        Text("1. Your cat remembers your actions;")
                        Text("2. Take care that he does not die;")
                        Text("3. Buy items to play with the cat;")
                        Text("4. Explore console commands;")
                        
                    }.font(.footnote)
                    
                    Button(action: {
                        startFakeLoading()
                    }, label: {
                        HStack {
                            if loading == false {
                                Image(systemName: "cpu.fill")
                            } else {
                                ProgressView().tint(.white)
                                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 3))
                            }
                            Text(buttonText).bold()
                                .contentTransition(.symbolEffect)
                        }
                    })
                    .foregroundStyle(.white)
                    .padding(.horizontal,12)
                    .padding(.vertical,9)
                    .background(.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Spacer()
                    
                    Text("Created by 01lab ")
                }
                Spacer()
            }
        } .padding()
    }
}

#Preview {
    IntroView(model: GameViewController())
        .preferredColorScheme(.light)
}
