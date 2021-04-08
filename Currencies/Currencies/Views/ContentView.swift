//
//  ContentView.swift
//  Currencies
//
//  Created by Asim Parvez on 20/02/2021.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - Constants
    private struct Constants {
        static let AmountPlaceHolder = "Enter Amount here"
        static let ConvertButtonTitle = "Convert"
        static let ScreenTitle = "Currencies"
        static let ErrorMessageTitle = "Error"
        static let AlertOKButtonText = "OK"
    }
    
    // MARK: - State
    @StateObject private var viewModel = CurrencyListViewModel()
    @State var showCurrencySelection = false
    
    // MARK: - View
    var body: some View {
        
        NavigationView {
                VStack(spacing: 8) {
                    Form {
                        Section {
                            amountTextField
                            selectCurrencyField
                        }//: - Section
                        Section {
                            convertButton
                        }
                        .disabled(viewModel.disableConversion) //: - Section
                    }.frame(height: 220) //: - Form
                    exchangeRatesList
                }.navigationBarTitle(Constants.ScreenTitle) //: - VStack
        }.navigationBarTitleDisplayMode(.inline) //: - NavigationView
        .onTapGesture {
            dismissKeyboard()
        }
        .alert(isPresented: $viewModel.showErrorAlert) {
            errorAlert
        }
    }//: - End
    
    
    // MARK: - View Components
    var amountTextField: some View {
        TextField(Constants.AmountPlaceHolder, text: $viewModel.amountToConvert)
            .keyboardType(.decimalPad)
    }
    
    var selectCurrencyField: some View {
        Text(viewModel.selectedCurrency)
            .foregroundColor(.blue)
            .onTapGesture {
                showCurrencySelection = true
            }
            .sheet(isPresented: $showCurrencySelection,
                   content: {
                    SearchView(show: $showCurrencySelection,
                               selectedIndex: $viewModel.selectedCurrencyIndex,
                             list: viewModel.currenciesList.map({$0.currencyCode + " " + $0.currencyName}
                             )
                    )
                }
            )
    }
    
    var convertButton: some View {
        Text(Constants.ConvertButtonTitle)
            .foregroundColor(viewModel.disableConversion ? .gray : .blue)
            .onTapGesture {
                viewModel.getExchangeRates()
        }
    }
    
    var exchangeRatesList: some View {
        List(viewModel.exchangeRates, id: \.currencyCode, rowContent: {item in
            VStack(alignment: .leading, spacing: 6) {
                Text(item.currencyCode)
                Text("\(item.exchangeRate)")
            }
        }).frame(minHeight: 100)
    }
    
    var errorAlert: Alert {
        Alert(title: Text(Constants.ErrorMessageTitle),
              message: Text(viewModel.errorMessage),
              dismissButton: .default(Text(Constants.AlertOKButtonText)))
    }
    
    // MARK: - Helper functions
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
