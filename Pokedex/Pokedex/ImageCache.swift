//
//  ImageCache.swift
//  Pokedex
//
//  Created by Aaditya Saini on 9/30/25.
//

import UIKit

// URLCache
final class CachedURLSession {
    static let shared: URLSession = {
        let cache = URLCache(
            memoryCapacity: 20 * 1024 * 1024, // 20 MB stored in memory
            diskCapacity: 100 * 1024 * 1024,  // 100 MB stored on disk
            diskPath: "PokemonImageCache"
        )

        let config = URLSessionConfiguration.default
        config.urlCache = cache
        config.requestCachePolicy = .useProtocolCachePolicy

        return URLSession(configuration: config)
    }()
}

// NSCache
final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    func get(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
