//
//  NetworkManager.swift
//  Currencies
//
//  Created by Asim Parvez on 20/02/2021.
//

import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager()
    let cache = ResponseCache()
    
    func getData<T: Codable>(endpoint: URL, type: T.Type, cachePolicy: CachePolicy) -> AnyPublisher<T, CurrenciesError> {
        
        if case .ignoreCache = cachePolicy {
            return getDataFromNetwork(endpoint: endpoint, type: type, cachePolicy: cachePolicy)
        }
        return getDataCacheEnabled(endpoint: endpoint, type: type, cachePolicy: cachePolicy)
    }
    
    // MARK: - Private
    
    private func getDataCacheEnabled<T: Codable>(endpoint: URL, type: T.Type, cachePolicy: CachePolicy) -> AnyPublisher<T, CurrenciesError> {
        if let data = cache.object(ofType: T.self, forKey: endpoint.absoluteString) {
            return AnyPublisher<T, CurrenciesError>(
                Result<T, CurrenciesError>.Publisher(data)
            )
        }
        return getDataFromNetwork(endpoint: endpoint, type: type, cachePolicy: cachePolicy)
    }
    
    private func getDataFromNetwork<T: Codable>(endpoint: URL, type: T.Type, cachePolicy: CachePolicy) -> AnyPublisher<T, CurrenciesError> {
        
        let decoder = JSONDecoder()
        
        return URLSession.shared
            .dataTaskPublisher(for: URLRequest(url: endpoint))
            .mapError {
                CurrenciesError.network(description: $0.localizedDescription)
            }
            .tryMap({ [weak self] (data, response) in
                guard let self = self else {
                    throw CurrenciesError.unknown(description: "Lost reference to self")
                }
                
                guard let response = try? decoder.decode(T.self, from: data) else {
                    throw self.makeError(data: data)
                }
                self.cache(data, endpoint: endpoint, cachePolicy: cachePolicy)
                return response
                
//                if let response = try? decoder.decode(T.self, from: data) {
//                    return response
//                }
//
//                if let responseError = try? decoder.decode(ServerError.self, from: data) {
//                    throw CurrenciesError.server(description: responseError.error.info)
//                }else {
//                    throw CurrenciesError.parsing(description: "Failed to parse")
//                }
            })
            .mapError{($0 as? CurrenciesError ?? .unknown(description: "An unknown error occured"))}
            .eraseToAnyPublisher()
        
        
        
        //        return URLSession.shared
        //            .dataTaskPublisher(for: URLRequest(url: endpoint))
        //            .mapError { error in
        //                .network(description: error.localizedDescription)
        //            }
        //            .flatMap(maxPublishers: .max(1)) { [unowned self] pair in
        //                self.decode(pair.data, endpoint: endpoint, cachePolicy: cachePolicy)
        //            }
        //            .eraseToAnyPublisher()
    }
    
//    private func decode<T: Codable>(_ data: Data, endpoint: URL, cachePolicy: CachePolicy) -> AnyPublisher<T, CurrenciesError> {
//        let decoder = JSONDecoder()
//
//
//
//        guard let object = try? decoder.decode(T.self, from: data) else {
//            return AnyPublisher<T, CurrenciesError>.init(
//                Result<T, CurrenciesError>.Publisher(makeError(data: data)))
//        }
//        cache(data, endpoint: endpoint, cachePolicy: cachePolicy)
//        return AnyPublisher<T, CurrenciesError>(
//            Result<T, CurrenciesError>.Publisher(object)
//        )
//    }
    
    private func makeError(data: Data) -> CurrenciesError {
        var error: CurrenciesError!
        let decoder = JSONDecoder()
        if let responseError = try? decoder.decode(ServerError.self, from: data) {
            error = CurrenciesError.server(description: responseError.error.info)
        }else {
            error = .parsing(description: "Failed to parse")
        }
        return error
    }
    
    private func cache(_ data: Data, endpoint: URL, cachePolicy: CachePolicy) {
        
        switch cachePolicy {
        case .cachePolicy(config: let config):
            cache.setObject(data, forKey: endpoint.absoluteString, config: config)
        case .defaultPolicy:
            cache.setObject(data, forKey: endpoint.absoluteString)
        case .ignoreCache:
            break
        }
    }
}
