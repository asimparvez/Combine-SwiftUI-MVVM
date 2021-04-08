//
//  CurrenciesTests.swift
//  CurrenciesTests
//
//  Created by Asim Parvez on 20/02/2021.
//

import XCTest
import Combine
@testable import Currencies

class CurrenciesTests: XCTestCase {
    
    var viewModel: CurrencyListViewModel!
    var mockClient = MockCurrenciesClient()
    
    override func setUp() {
        viewModel = CurrencyListViewModel(client: mockClient)
    }
    
    // MARK: - Validation
    func testThatConvertButtonIsDisabledInitiallyWithCurrenciesPopulated() {
        // Given view model is in initial state with data
        viewModel.currenciesList = MockData.makeCurrencies().list
        // Initially The Convert Button should be disabled
        XCTAssertTrue(self.viewModel.disableConversion)
    }
    
    func testThatConvertButtonIsDisabledWhenCurrencyIsSelectedButAmountIsEmpty() {
        // Given view model is in initial state with data
        viewModel.currenciesList = MockData.makeCurrencies().list
        // And currency is selected for conversion
        viewModel.selectedCurrencyIndex = 2
        // The Convert Button should stay disabled, since amount is empty
        XCTAssertTrue(self.viewModel.disableConversion)
    }
    
    func testThatConvertButtonIsDisabledWhenCurrencyIsSelectedButAmountAmountIsInValid() {
        // Given view model is in initial state with data
        viewModel.currenciesList = MockData.makeCurrencies().list
        // And currency is selected for conversion
        viewModel.selectedCurrencyIndex = 2
        // But amount is invalid
        viewModel.amountToConvert = "1.2.32...33.."
        // The Convert Button should stay disabled, since amount is invalid
        XCTAssertTrue(self.viewModel.disableConversion)
    }
    
    func testThatConvertButtonIsEnabledWhenCurrencyIsSelectedAndAmountAmountIsValid() {
        // Given view model is in initial state with data
        viewModel.currenciesList = MockData.makeCurrencies().list
        // And currency is selected for conversion
        viewModel.currenciesList = MockData.makeCurrencies().list
        viewModel.selectedCurrencyIndex = 2
        // But amount is invalid
        viewModel.amountToConvert = "23.234"
        // The Convert Button should be enabled, since amount is valid
        XCTAssertFalse(self.viewModel.disableConversion)
    }
    
    // MARK: - Currency Selection
    
    func testThatInitiallyCurrencySelectionReturnsPlaceholderValue() {
        // Given view model is in initial state with data
        viewModel.currenciesList = MockData.makeCurrencies().list
        // The Convert Button should be enabled, since amount is valid
        XCTAssertEqual(CurrencyListViewModel.Constants.SelectCurrencyPlaceholder, self.viewModel.selectedCurrency)
    }
    
    func testThatInitiallyCurrencySelectionReturnsCurrencyCodeAndNameWhenCurrencyIsSelected() {
        // Given currency is selected for conversion with a valid amount
        let list = MockData.makeCurrencies().list
        viewModel.currenciesList = list
        viewModel.selectedCurrencyIndex = 2
        // The Convert Button should be enabled, since amount is valid
        XCTAssertEqual("\(list[2].currencyCode) \(list[2].currencyName)", self.viewModel.selectedCurrency)
    }
    
    // MARK: - Currencies list
    func testErrorOutputIsGeneratedWhenCurrenciesAPIFails() {
        // Given an error is set in mock client
        let errorMessage = "The server is down plz try later"
        mockClient.currenciesResponse = .failure(.server(description: errorMessage))
        // When view model is initialized with mock client
        viewModel = CurrencyListViewModel(client: mockClient)
        // Then error alert should be shown and currencies list should be empty
        wait(for: 0.5) { [weak self] _ in
            guard let self = self else { return }
            XCTAssertTrue(self.viewModel.showErrorAlert)
            XCTAssertEqual(errorMessage, self.viewModel.errorMessage)
            XCTAssertEqual(self.viewModel.currenciesList, [])
        }
    }
    
    func testListOutputIsGeneratedWhenCurrenciesAPIISSuccessful() {
        // Given list is set on mock client
        let list = MockData.makeCurrencies()
        mockClient.currenciesResponse = .success(list)
        // When view model is initialized with mock client
        viewModel = CurrencyListViewModel(client: mockClient)
        // Then list output should be generated
        wait(for: 0.5) { [weak self] _ in
            guard let self = self else { return }
            XCTAssertEqual(self.viewModel.currenciesList, list.list)
            XCTAssertFalse(self.viewModel.showErrorAlert)
        }
    }
    
    // MARK: - Exchange Rates
    func testErrorOutputIsGeneratedWhenExchangeRateAPIFails() {
        // Given an error is set in mock client
        let errorMessage = "The server is down plz try later"
        mockClient.exchangeResponse = .failure(.server(description: errorMessage))
        // And currency is selected for conversion
        viewModel.currenciesList = MockData.makeCurrencies().list
        viewModel.selectedCurrencyIndex = 2
        // When getExchangeRates input is received with selected currency index
        viewModel.getExchangeRates()
        // Then error alert should be shown and exchange rate list should be empty
        wait(for: 0.5) { [weak self] _ in
            guard let self = self else { return }
            XCTAssertTrue(self.viewModel.showErrorAlert)
            XCTAssertEqual(errorMessage, self.viewModel.errorMessage)
            XCTAssertEqual(self.viewModel.exchangeRates, [])
        }
    }
    
    func testNoOutputIsGeneratedWhenExchangeRateIsCalledWithoutCurrencySelection() {
        // Given list is set on mock client
        let list = MockData.makeExchangeRateItemsList()
        mockClient.exchangeResponse = .success(list)
        // And currency list is present with no selection
        viewModel.currenciesList = MockData.makeCurrencies().list
        // When getExchangeRates input is received with selected currency index
        viewModel.getExchangeRates()
        // Then out put remains unaffected
        wait(for: 0.5) { [weak self] _ in
            guard let self = self else { return }
            XCTAssertEqual(self.viewModel.exchangeRates, [])
            XCTAssertFalse(self.viewModel.showErrorAlert)
            XCTAssertEqual("", self.viewModel.errorMessage)
        }
    }
    
    func testListOutputIsGeneratedWhenExchangeRateAPIISSuccessful() {
        // Given list is set on mock client
        let list = MockData.makeExchangeRateItemsList()
        mockClient.exchangeResponse = .success(list)
        // And currency is selected for conversion with a valid amount
        viewModel.currenciesList = MockData.makeCurrencies().list
        viewModel.selectedCurrencyIndex = 2
        viewModel.amountToConvert = "1"
        // When getExchangeRates input is received with selected currency index
        viewModel.getExchangeRates()
        // Then list output should be generated
        wait(for: 2) { [weak self] _ in
            guard let self = self else { return }
            XCTAssertEqual(self.viewModel.exchangeRates, list.list)
            XCTAssertFalse(self.viewModel.showErrorAlert)
        }
    }
    
    // MARK: - Helper Method Tests
    func testConvertValuesReturnsNilIfViewModelAmountIsIncorrect() {
        // Given view model has invalid string in amount
        viewModel.amountToConvert = "1.2.3"
        let item = ExchangeRateItem(currencyCode: "USD", exchangeRate: 12)
        
        // Then it should return nil in response instead of a converted item
        XCTAssertNil(viewModel.convertValues(for: item))
    }
    
    func testConvertValuesReturnsCorrectItemIfViewModelAmountIsCorrect() {
        // Given view model has valid string in amount
        viewModel.amountToConvert = "2"
        let item = ExchangeRateItem(currencyCode: "USD", exchangeRate: 12)
        
        // When we convert item after multiplying with amount
        let convertedItem = viewModel.convertValues(for: item)
        
        // Then it should return nil in response instead of a converted item
        XCTAssertNotNil(convertedItem)
        XCTAssertEqual(convertedItem!.exchangeRate, 12*2)
    }
    
    func testThatGenericErrorMessageIsShownWhenNetworkFails() {
        // Given we have a network error
        let error = CurrenciesError.network(description: "network error")
        
        // When we show error
        viewModel.showError(error)
        
        // The error message should be generic
        XCTAssertEqual(viewModel.errorMessage, CurrencyListViewModel.Constants.GenericErrorMessage)
        XCTAssertTrue(self.viewModel.showErrorAlert)
    }
    
    func testThatGenericErrorMessageIsShownWhenParsingFails() {
        // Given we have a network error
        let error = CurrenciesError.parsing(description: "parsing error")
        
        // When we show error
        viewModel.showError(error)
        
        // The error message should be generic
        XCTAssertEqual(viewModel.errorMessage, CurrencyListViewModel.Constants.GenericErrorMessage)
        XCTAssertTrue(self.viewModel.showErrorAlert)
    }
    
    func testThatServerErrorMessageIsShownWhenServerSendsError() {
        // Given we have a network error
        let errorMsg = "server error"
        let error = CurrenciesError.server(description: errorMsg)
        
        // When we show error
        viewModel.showError(error)
        
        // The error message should be generic
        XCTAssertEqual(viewModel.errorMessage, errorMsg)
        XCTAssertTrue(self.viewModel.showErrorAlert)
    }
    
}


// Wait for cases where client methods are called, since the calls are async
extension XCTestCase {
    func wait(for duration: TimeInterval, handler: @escaping XCWaitCompletionHandler) {
        let waitExpectation = expectation(description: "Waiting")
        
        let time = DispatchTime.now() + duration
        DispatchQueue.main.asyncAfter(deadline: time) {
            waitExpectation.fulfill()
        }
        waitForExpectations(timeout: duration, handler: handler)
    }
}
