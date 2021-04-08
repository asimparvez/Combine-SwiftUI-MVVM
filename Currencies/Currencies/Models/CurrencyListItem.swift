//
//  CurrencyListItem.swift
//  Currencies
//
//  Created by Asim Parvez on 20/02/2021.
//

import Foundation

struct CurrencyListItem: Equatable {
    let currencyCode: String
    let currencyName: String
}


struct CurrenciesList: Codable {
    
    let list: [CurrencyListItem]
    
    enum CodingKeys: String, CodingKey {
        case currencies
    }
    
    init(list: [CurrencyListItem]) {
        self.list = list
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let currencies = try values.decode([String:String].self, forKey: .currencies)
            
        var list = [CurrencyListItem]()
        for (key,value) in currencies {
            list.append(CurrencyListItem(currencyCode: key, currencyName: value))
        }
        self.list = list
    }
    
    func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
        var dictionary = [String: String]()
        list.forEach({ item in
            dictionary[item.currencyCode] = item.currencyName
        })
        try container.encode(dictionary, forKey: .currencies)
    }
    
}




