//
//  ViewModel.swift
//  Currencies
//
//  Created by Asim Parvez on 20/02/2021.
//

import Foundation
import Combine
import SwiftUI

protocol CurrencyListViewModelInputs {
    func getSupportedCurrencies()
    func getExchangeRates()
    var amountToConvert: String {get set}
    var selectedCurrencyIndex: Int? {get set}
}

protocol CurrencyListViewModelOutputs: ObservableObject {
    var currenciesList: [CurrencyListItem] { get }
    var exchangeRates: [ExchangeRateItem] { get }
    var disableConversion: Bool { get }
    var errorMessage: String { get }
    var showErrorAlert: Bool { get }
    var selectedCurrency: String { get }
}

typealias CurrencyListViewModelType = CurrencyListViewModelInputs & CurrencyListViewModelOutputs

final class CurrencyListViewModel: CurrencyListViewModelType {
    
    struct Constants {
        static let SelectCurrencyPlaceholder = "Select Currency"
        static let GenericErrorMessage = "Some thing went wrong. Please try again later"
    }
    
    // MARK: - Private Declarations
    private var subscriptions = Set<AnyCancellable>()
    private let client: CurrencyClientProtocol
    
    // MARK: - init
    init(client: CurrencyClientProtocol = CurrencyClient()) {
        self.client = client
        getSupportedCurrencies()
    }
    
    // MARK: - Outputs
    @Published var currenciesList: [CurrencyListItem] = []
    @Published var exchangeRates: [ExchangeRateItem] = []
    @Published var errorMessage = ""
    @Published var showErrorAlert = false
    var disableConversion: Bool {
        if let _ = Double(amountToConvert), let _ = selectedCurrencyIndex {
            return false
        }
        return true
    }
    var selectedCurrency: String {
        guard let index = selectedCurrencyIndex else {
            return Constants.SelectCurrencyPlaceholder
        }
        return "\(currenciesList[index].currencyCode) \(currenciesList[index].currencyName)"
    }
    
    // MARK: - Inputs
    @Published var amountToConvert = ""
    @Published var selectedCurrencyIndex: Int?
    func getSupportedCurrencies() {
        
        client.getAllCurrenciesList(cachePolicy: .defaultPolicy).receive(on: RunLoop.main).sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                self?.showError(error)
                self?.currenciesList = []
            }
        }, receiveValue: { [weak self] currencies in
            self?.currenciesList = currencies.list.sorted{ $0.currencyCode < $1.currencyCode }
        })
        .store(in: &subscriptions)
    }
    
    func getExchangeRates() {
        
        guard let index = selectedCurrencyIndex else {
            return
        }
        let currency =  currenciesList[index].currencyCode
        client.getExchangeRateFor(currency: currency, cachePolicy: .defaultPolicy).receive(on: RunLoop.main).sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                self?.showError(error)
                self?.exchangeRates = []
            }
        }, receiveValue: { [weak self] exchangeItems in
            self?.exchangeRates = exchangeItems.list.sorted{ $0.currencyCode < $1.currencyCode }
                .compactMap{ [weak self] item in
                    return self?.convertValues(for: item)
                }
        })
        .store(in: &subscriptions)
    }
    
    // MARK: - Helper Methods
    func convertValues(for item: ExchangeRateItem) -> ExchangeRateItem? {
        guard let amountToConvert: Double = Double(amountToConvert) else {
            return nil
        }
        let totalAmount = item.exchangeRate * amountToConvert
        return ExchangeRateItem(currencyCode: item.currencyCode, exchangeRate: totalAmount)
    }
    
    func showError(_ error: CurrenciesError) {
        switch error {
        case .server(let description):
            errorMessage = description
        default:
            errorMessage = Constants.GenericErrorMessage
        }
        showErrorAlert = true
    }
}


