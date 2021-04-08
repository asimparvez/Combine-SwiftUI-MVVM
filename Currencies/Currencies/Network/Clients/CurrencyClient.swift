//
//  CurrencyClient.swift
//  Currencies
//
//  Created by Asim Parvez on 20/02/2021.
//

import Foundation
import Combine


protocol CurrencyClientProtocol {
    func getAllCurrenciesList(cachePolicy: CachePolicy) -> AnyPublisher<CurrenciesList, CurrenciesError>
    func getExchangeRateFor(currency: String, cachePolicy: CachePolicy) -> AnyPublisher<ExchangeRateItemList, CurrenciesError>
}

class CurrencyClient: CurrencyClientProtocol {
    
    func getAllCurrenciesList(cachePolicy: CachePolicy) -> AnyPublisher<CurrenciesList, CurrenciesError> {
        return NetworkManager.shared.getData(endpoint: CurrencyEndPoints.list.buildURL(), type: CurrenciesList.self, cachePolicy: cachePolicy)
    }
    
    
    func getExchangeRateFor(currency: String, cachePolicy: CachePolicy) -> AnyPublisher<ExchangeRateItemList, CurrenciesError> {
        return NetworkManager.shared.getData(endpoint: CurrencyEndPoints.live(source: currency).buildURL(), type: ExchangeRateItemList.self, cachePolicy: cachePolicy)
    }
    
}
