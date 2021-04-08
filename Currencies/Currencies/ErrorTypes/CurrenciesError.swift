//
//  CurrenciesError.swift
//  Currencies
//
//  Created by Asim Parvez on 20/02/2021.
//

import Foundation

enum CurrenciesError: Error {
    case parsing(description: String)
    case server(description: String)
    case network(description: String)
    case unknown(description: String)
}

