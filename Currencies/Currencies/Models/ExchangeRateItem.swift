//
//  ExchangeRateItem.swift
//  Currencies
//
//  Created by Asim Parvez on 20/02/2021.
//

import Foundation

import Foundation

struct ExchangeRateItem: Equatable {
    let currencyCode: String
    let exchangeRate: Double
}


struct ExchangeRateItemList: Codable {
    
    let list: [ExchangeRateItem]
    
    enum CodingKeys: String, CodingKey {
        case quotes
    }
    
    init(list: [ExchangeRateItem]) {
        self.list = list
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let currencies = try values.decode([String:Double].self, forKey: .quotes)
            
        var list = [ExchangeRateItem]()
        for (key,value) in currencies {
            list.append(ExchangeRateItem(currencyCode: key, exchangeRate: value))
        }
        self.list = list
    }
    
    
    func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
        var dictionary = [String: Double]()
        list.forEach({ item in
            dictionary[item.currencyCode] = item.exchangeRate
        })
        try container.encode(dictionary, forKey: .quotes)
    }
    
}




