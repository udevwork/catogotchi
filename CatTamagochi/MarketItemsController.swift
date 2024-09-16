//
//  MarketItemsController.swift
//  CatTamagochi
//
//  Created by Denis Kotelnikov on 13.09.2024.
//

import Foundation
import SwiftyJSON

class MarketItemsController: ObservableObject {
    
    private let json: JSON
    
    var items: [MarketItem] = []
    
    init() {
        let path = Bundle.main.path(forResource: "Marketitems", ofType: "json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: path!))
        json = try! JSON(data: data)
        
        do {
            let objData = try json.rawData()
            items = try JSONDecoder().decode([MarketItem].self, from: objData)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

struct MarketItem: Codable, Identifiable {
    let id: String?
    let itemName: String?
    let description: String?
    let image: String?
    let price: Int?
}
