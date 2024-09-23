//
//  CatMarket.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 07.09.2024.
//

import SwiftUI
import ConfettiSwiftUI
import FastAppLibrary
import Glur
import SwiftUITooltip

struct CatMarket: View {
    
 
    @StateObject var marketDB = MarketItemsController()
    let gamecontroller: GameViewController
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10, content: {
            Text("Market").font(.title).padding(.horizontal, 40)
            
            HorizontalSnapGalleryView(
                containerWidth: UIScreen.main.bounds.width,
                galleryHeight: 330,
                elementSpacing: 10,
                elemetsEgesOffes: 40,
                data: $marketDB.items) { item in
                    CatMarketItemView(item: item)
                }
        })
    }
    
   
}

struct CatMarketItemView: View {

    @StateObject var catParameters = CatParameters.shared
    @State private var counter: Int = 0
    var item: MarketItem
    
    init(item: MarketItem) {
        self.item = item
    }
    
    func isPurchased(id: String) -> Bool {
        catParameters[Item.id(id)] != nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
           
            if let img = item.image {
                ZStack(alignment: .bottomLeading, content: {
                 
                    Image(img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    
                        .overlay(content: {
                            LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear, Color.clear]), startPoint: .top, endPoint: .bottom).opacity(0.5)
                            LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear, Color.clear]), startPoint: .bottom, endPoint: .top).opacity(0.9)
                        })
                      
                        .glur(radius: 38.0,
                              offset: 0.8,
                              interpolation: 0.6,
                              direction: .down
                        )
                     
                
                    VStack(alignment: .leading) {
                        Text(item.itemName ?? "")
                         
                            .fontWeight(.black)
                            .foregroundStyle(.white)
                            .shadow(color: .black, radius: 10)
                        Spacer()
                        
                        if isPurchased(id: item.id ?? "") == false {
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
                                .padding(.horizontal,12)
                                .padding(.vertical,7)
                                .background(.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 25.0))
                                
                            })
                            .disabled((item.price ?? 0) > catParameters.money)
                            .opacity((item.price ?? 0) > catParameters.money ? 0.5 : 1)
                        }
                        Text(item.description ?? "")
                            .foregroundStyle(.white)
                    }
                    .padding(20)
                })
            }
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20.0))
        .confettiCannon(
            counter: $counter,
            repetitions: 3,
            repetitionInterval: 0.7
        )
        .frame(width: 300, height: 300)
    }
}




#Preview {
//    CatMarket(gamecontroller: GameViewController())
    GameView()
//    VStack {
//        Spacer()
//        CatMarketItemView(item: .init(id: "1", itemName: "Slava Kornilov", description: "Slava Kornilov | Creative Director at @GeexArts. Awwwards Jury 2022 | Connect with them on Dribbble;", image: "ring_of_power_for a cat", price: 20))
//            .frame(width: 330, height: 520)
//        Spacer()
//    }.frame(width: .infinity)
//    .background(.screenBack)
   
}
