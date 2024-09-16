//
//  StatParameterView.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 15.09.2024.
//

import SwiftUI

struct StatParameterView: View {
    @State private var animationsRunning = false
    var progressValue: Int
    var iconName: String
    var body: some View {
        VStack(spacing: 15) {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25, alignment: .center)
                    .symbolEffect(.bounce.down, value: animationsRunning)
                DotsProgressBar(value: progressValue)
                
            }
            Text("\(progressValue)%")
            
        }.onTapGesture {
            withAnimation {
                animationsRunning.toggle()
            }
        }
    }
}


struct DotsProgressBar: View {
    var value: Int // Значение от 0 до 100

    private var filledDots: Int {
        return max(0, min(10, value / 10))
    }

    func crop(i: Int) -> CGSize {
        let val = max(0, min(1, Double(filledDots)/Double(i)))
        return CGSize(width: val,
                            height: val)
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<10) { index in
                Circle()
                    .fill(index < filledDots ? .accent : Color.gray)
                    .opacity(Double(filledDots)/Double(index))
//                    .scaleEffect(crop(i: index))
                    .frame(width: 4, height: 4)
            }
        }
    }
}

#Preview {
    HStack {
        StatParameterView(progressValue: 25, iconName: "heart")
    }
    .frame(width: 400, height: 400, alignment: .center)
    .background(.screenBack)
    .fontDesign(.monospaced)
}
