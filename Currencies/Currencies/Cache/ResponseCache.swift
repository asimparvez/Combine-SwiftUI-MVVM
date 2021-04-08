//
//  ResponseCache.swift
//  Currencies
//
//  Created by Asim Parvez on 21/02/2021.
//

import Foundation
import Cache

protocol ResponseCacheType {
    func setObject<T: Codable>(_ object: T, forKey key: String, config: CacheConfig)
    func object<T: Codable>(ofType _: T.Type, forKey key: String) -> T?
    func remove(for key: String)
    func removeAll()
}


public class ResponseCache: ResponseCacheType {

    static let DefaultMaxDiskSize: UInt = 10000000
    let diskConfig = DiskConfig(name: "Floppy", maxSize: DefaultMaxDiskSize)
    let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    private lazy var internalStorage: Storage<String, Data>? = {
        try? Cache.Storage<String, Data>(
          diskConfig: diskConfig,
          memoryConfig: memoryConfig,
            transformer: TransformerFactory.forData())
    }()
    
    
    // MARK: - ResponseCacheType
    func setObject<T: Codable>(_ object: T, forKey key: String, config: CacheConfig = .defaultConfig) {
                
        let expiry = Expiry.date(Date().addingTimeInterval(config.expiryTime))
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            try? internalStorage?.setObject(encoded, forKey: key, expiry: expiry)
        }
    }

    func object<T: Codable>(ofType _: T.Type, forKey key: String) -> T? {
        
        try? internalStorage?.removeExpiredObjects()
        guard let data = try? internalStorage?.object(forKey: key) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }

    func remove(for key: String) {
        try? internalStorage?.removeObject(forKey: key)
    }
    
    func removeAll() {
        try? internalStorage?.removeAll()
    }

}
