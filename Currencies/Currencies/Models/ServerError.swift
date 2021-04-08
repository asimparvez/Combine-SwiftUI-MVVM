//
//  ServerError.swift
//  Currencies
//
//  Created by Asim Parvez on 20/02/2021.
//

import Foundation

struct ServerError : Codable {
    let error: ServerErrorDetails
}

struct ServerErrorDetails : Codable {
    let code: Int
    let info: String
}
