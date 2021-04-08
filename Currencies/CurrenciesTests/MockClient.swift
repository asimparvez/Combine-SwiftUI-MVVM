//
//  MockClient.swift
//  CurrenciesTests
//
//  Created by Asim Parvez on 21/02/2021.
//

import Foundation
import Combine
@testable import Currencies


final class MockCurrenciesClient: CurrencyClientProtocol {
    
    var currenciesResponse: Result<CurrenciesList, CurrenciesError> = .success(CurrenciesList(list: []))
    func getAllCurrenciesList(cachePolicy: CachePolicy) -> AnyPublisher<CurrenciesList, CurrenciesError> {
        AnyPublisher<CurrenciesList, CurrenciesError>(
            Result<CurrenciesList, CurrenciesError>.Publisher(currenciesResponse)
        )
    }
    
    var exchangeResponse: Result<ExchangeRateItemList, CurrenciesError> = .success(ExchangeRateItemList(list: []))
    func getExchangeRateFor(currency: String, cachePolicy: CachePolicy) -> AnyPublisher<ExchangeRateItemList, CurrenciesError> {
        AnyPublisher<ExchangeRateItemList, CurrenciesError>(
            Result<ExchangeRateItemList, CurrenciesError>.Publisher(exchangeResponse)
        )
    }
    
}

class MockData {
    
    static func makeCurrencies() -> CurrenciesList {
        
        let list = [Currencies.CurrencyListItem(currencyCode: "AED", currencyName: "Arab Emirates Dirham"),
                    Currencies.CurrencyListItem(currencyCode: "AUD", currencyName: "Australian Dollar"),
                    Currencies.CurrencyListItem(currencyCode: "CAD", currencyName: "Canadian Dollar"),
                    Currencies.CurrencyListItem(currencyCode: "GBP", currencyName: "Breat Britain Pound"),
                    Currencies.CurrencyListItem(currencyCode: "JPY", currencyName: "Japanese Yen"),
                    Currencies.CurrencyListItem(currencyCode: "KWR", currencyName: "Kuwaiti Riyal"),
                    Currencies.CurrencyListItem(currencyCode: "MYR", currencyName: "Malaysian Ringit"),
                    Currencies.CurrencyListItem(currencyCode: "PKR", currencyName: "Pakistan Rupee"),
                    Currencies.CurrencyListItem(currencyCode: "SGD", currencyName: "Singapore Dollar"),
                    Currencies.CurrencyListItem(currencyCode: "USD", currencyName: "US Dollar")
        ]
        return CurrenciesList(list: list)
        
    }
    
    static func makeExchangeRateItemsList() -> ExchangeRateItemList {
        
        let list = [Currencies.ExchangeRateItem(currencyCode: "AED", exchangeRate: 12.69),
                    Currencies.ExchangeRateItem(currencyCode: "AUD", exchangeRate: 12.51),
                    Currencies.ExchangeRateItem(currencyCode: "CAD", exchangeRate: 12.44),
                    Currencies.ExchangeRateItem(currencyCode: "GBP", exchangeRate: 1.68),
                    Currencies.ExchangeRateItem(currencyCode: "JPY", exchangeRate: 12.73),
                    Currencies.ExchangeRateItem(currencyCode: "KWR", exchangeRate: 11.43),
                    Currencies.ExchangeRateItem(currencyCode: "MYR", exchangeRate: 2.3),
                    Currencies.ExchangeRateItem(currencyCode: "PKR", exchangeRate: 12.89),
                    Currencies.ExchangeRateItem(currencyCode: "SGD", exchangeRate: 12.33)
        ]
        return ExchangeRateItemList(list: list)
    }
}
