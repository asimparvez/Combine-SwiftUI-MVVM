//
//  Cache.swift
//  Currencies
//
//  Created by Asim Parvez on 21/02/2021.
//

import Foundation

enum CachePolicy {
    case ignoreCache
    case defaultPolicy
    case cachePolicy(config: CacheConfig)
}


struct CacheConfig: Equatable {
    static let DefaultCacheExpiry: TimeInterval = 60 * 30
    let expiryTime: TimeInterval
    
    init(expiryTime: TimeInterval = DefaultCacheExpiry) {
        self.expiryTime = expiryTime
    }
    
    static let defaultConfig = CacheConfig()
}
