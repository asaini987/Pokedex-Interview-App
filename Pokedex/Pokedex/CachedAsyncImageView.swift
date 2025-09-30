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
            // loading
            ProgressView()
                .scaleEffect(1.2)
                .opacity(showingProgress ? 1 : 0)

            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else if didFail {
                Image(systemName: "questionmark.square.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .task {
            guard let url, uiImage == nil, !didFail else {
                return
            }

            // check NSCache (decoded UIImage in memory)
            if let cached = ImageCache.shared.get(forKey: url.absoluteString) {
                uiImage = cached
                return
            }

            // check load from URLCache/network
            if let image = await loadImage(from: url) {
                ImageCache.shared.set(image, forKey: url.absoluteString) // store in NSCache
                uiImage = image
            } else {
                didFail = true
            }
        }
    }

    private var showingProgress: Bool {
        uiImage == nil && !didFail && url != nil
    }

    private func loadImage(from url: URL) async -> UIImage? {
        do {
            let (data, _) = try await CachedURLSession.shared.data(from: url)
            return await Task.detached(priority: .userInitiated) {
                UIImage(data: data)
            }.value
        } catch {
            return nil
        }
    }
}
