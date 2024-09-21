//
//  CardsWsipe.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 17.09.2024.
//

import SwiftUI

import FastAppLibrary

struct test: Identifiable {
    var id = UUID()
    
    var text: String
}

struct CardSwipeView: View {
    @State var cards : [test] = [
        test(text: "sadf"),
        test(text: "hhnnknmk"),
        test(text: "2342"),
        test(text: ";a;a;a;")
    ]

    var body: some View {
        HorizontalSnapGalleryView(
            containerWidth: UIScreen.main.bounds.width,
            galleryHeight: 300,
            elementSpacing: 20,
            elemetsEgesOffes: 30,
            data: $cards) { i in
                Text(i.text).frame(maxWidth: .infinity)
                    .background(.green)
            }
    }
}

struct CardView: View {
    var cardTitle: String

    var body: some View {
        ZStack {
            Color.blue
            Text(cardTitle)
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}


#Preview {
    CardSwipeView()
}
