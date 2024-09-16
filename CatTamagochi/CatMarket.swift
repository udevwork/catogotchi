//
//  CatMarket.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 07.09.2024.
//

import SwiftUI
import ConfettiSwiftUI
import FastAppLibrary

struct CatMarket: View {
    
    @State private var counter: Int = 0
    @StateObject var catParameters = CatParameters.shared
    @StateObject var marketDB = MarketItemsController()
    let gamecontroller: GameViewController
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView {
               
                Rectangle().frame(height: 60).foregroundStyle(.clear)
                
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(marketDB.items, id: \.id) { item in
                        VStack(alignment: .leading, spacing: 0) {
                            if let img = item.image {
                                Image(img)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: UIScreen.main.bounds.width/2 )
                                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                                   
                            }
                            VStack(alignment: .leading, spacing: 10) {
                                Text(item.itemName ?? "")
                                    .font(.headline)
                                    .bold()
                                Text(item.description ?? "")
                                    .font(.footnote)
                                    .foregroundStyle(.black.opacity(0.7))
                            }.padding(EdgeInsets(top: 17, leading: 17, bottom: 0, trailing: 17))
                            
                            Spacer()
                            if isPurchased(id: item.id ?? "") {
                                Text("Owned!")
                                    .foregroundStyle(.white)
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(.black)
                                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                                    .padding(17)
                                
                            } else {
                                Button(action: {
                                    if let id = item.id, let cost = item.price {
                                        catParameters[Item.id(id)] = item.itemName ?? ""
                                        withAnimation {
                                            catParameters.changeMoney(val: -cost)
                                        }
                                        counter += 1
                                        Haptic.impact(style: .heavy)
                                    }
                                }, label: {
                                    
                                    HStack {
                                        Image("coins")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 25, height: 10)
                                        Text("\(item.price ?? 0)")
                                            .bold()
                                           
                                    } 
                                    .foregroundStyle(.white)
                                    .bold()
                                    .frame(maxWidth: .infinity)
                                    .padding(10)
                                    .background(.black)
                                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                                    
                                })
                                .padding(17)
                                .disabled((item.price ?? 0) > catParameters.money)
                            
                            }
                        }
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 36.0))
                        .opacity((item.price ?? 0) > catParameters.money ? 0.5 : 1)
                    }
                }
            }.confettiCannon(counter: $counter, repetitions: 3, repetitionInterval: 0.7)
            
            HStack(spacing: 5) {
                HStack {
                    Image("coins")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 25, height: 10)
                    Text("\(catParameters.money)").bold()
                }
                .foregroundStyle(.white)
                .padding(.horizontal,12)
                .padding(.vertical,9)
                .background(.accent)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                                
                HStack {
                    Text("MARKET").bold()
                }
                .foregroundStyle(.white)
                .padding(.horizontal,12)
                .padding(.vertical,9)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(10)

            
        }.background(.screenBack)
    }
    
    func isPurchased(id: String) -> Bool {
        catParameters[Item.id(id)] != nil
    }
}

#Preview {
    CatMarket(gamecontroller: GameViewController())
}
