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
            Text(item.itemName ?? "")
                .padding(EdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 10))
            if let img = item.image {
                ZStack(alignment: .bottomLeading, content: {
                    Image(img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay(content: {
                            LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear, Color.clear]), startPoint: .bottom, endPoint: .top)
                        })
                        .frame(height: 290)
                        .glur(radius: 38.0,
                              offset: 0.6,
                              interpolation: 0.9,
                              direction: .down
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                        .frame(height: 290)
                    VStack(alignment: .leading) {
                        if isPurchased(id: item.id ?? "") {
                            Text("Owned!")
                                .foregroundStyle(.white)
                                .bold()
                                .padding(.horizontal,15)
                                .padding(.vertical,7)
                                .background(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 25.0))
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
                                
                                .padding(.horizontal,12)
                                .padding(.vertical,7)
                                .background(.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 25.0))
                                
                            })
                            .disabled((item.price ?? 0) > catParameters.money)
                        }
                        Text(item.description ?? "")
                            .foregroundStyle(.white)
                    }
                    .padding(20)
                })
            }
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 15.0))
        .opacity((item.price ?? 0) > catParameters.money ? 0.5 : 1)
        .confettiCannon(
            counter: $counter,
            repetitions: 3,
            repetitionInterval: 0.7
        )
    }
}
#Preview {
    //CatMarket(gamecontroller: GameViewController())
    GameView()
}
