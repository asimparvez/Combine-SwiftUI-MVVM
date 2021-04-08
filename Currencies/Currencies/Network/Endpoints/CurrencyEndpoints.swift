//
//  CurrencyEndpoints.swift
//  Currencies
//
//  Created by Asim Parvez on 20/02/2021.
//

import Foundation

enum CurrencyEndPoints {
    case list
    case live(source: String)
}

extension CurrencyEndPoints {
    
    private struct APIConstants {
      static let scheme = "http"
      static let host = "api.currencylayer.com"
      static let accessKey = "6f32534cc6f6fee1dae72a8d6a582088"
    }
    
    var endPoint: String {
        switch self {
        case .list:
            return "/list"
        case .live(_):
            return "/live"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .list:
            return []
        case let .live(source):
            return [URLQueryItem(name: "source", value: source)]
        }
    }
    
    func buildURL() -> URL {
        
        var components = URLComponents()
        components.scheme = APIConstants.scheme
        components.host = APIConstants.host
        components.path = endPoint
        components.queryItems = queryItems + [URLQueryItem(name: "access_key", value: APIConstants.accessKey)]
        
        guard let url = components.url else {
            fatalError("\(endPoint) failed to build url")
        }
        return url
    }
}
