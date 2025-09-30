//
//  CachedAsyncImageView.swift
//  Pokedex
//
//  Created by Aaditya Saini on 9/29/25.
//

import SwiftUI

struct CachedAsyncImage: View {
    let url: URL?

    @State private var uiImage: UIImage?
    @State private var didFail = false

    var body: some View {
        ZStack {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else if didFail {
                Image(systemName: "questionmark.square.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
            } else if url != nil {
                ProgressView()
                    .scaleEffect(1.2)
            } else {
                Image(systemName: "questionmark.square.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .task {
            if let url, uiImage == nil, !didFail {
                uiImage = await loadImage(from: url)
                if uiImage == nil {
                    didFail = true
                }
            }
        }
    }

    private func loadImage(from url: URL) async -> UIImage? {
        do {
            let (data, response) = try await cachedSession.data(from: url)
            if let http = response as? HTTPURLResponse {
//                        print("Headers for \(url): \(http.allHeaderFields)")
                    }
            return UIImage(data: data)
        } catch {
//            print("Failed to load \(url): \(error.localizedDescription)")
            return nil
        }
    }
}

private let cachedSession: URLSession = {
    let cache = URLCache(
        memoryCapacity: 50 * 1024 * 1024, // 50 mb
        diskCapacity: 200 * 1024 * 1024, // 200 mb
        diskPath: "PokemonImageCache"
    )

    let config = URLSessionConfiguration.default
    config.urlCache = cache
    config.requestCachePolicy = .returnCacheDataElseLoad
    
    return URLSession(configuration: config)
}()
