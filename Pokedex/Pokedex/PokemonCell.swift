//
//  PokemonCell.swift
//  Pokedex
//
//  Created by Aaditya Saini on 9/27/25.
//

import SwiftUI

struct PokemonCell: View {
    let resource: PokemonAPIResource
    let detail: PokemonDetail?
    
    var body: some View {
        VStack {
            ZStack {
                Color.clear

                if let spriteURL = detail?.sprites.frontDefault, let url = URL(string: spriteURL) {
                    CachedAsyncImage(url: url)
                        .id(url)
                } else if detail != nil { // no sprite
                    Image(systemName: "questionmark.square.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                }
            }
            .aspectRatio(DrawingConstants.aspectRatio, contentMode: .fit)

            Text(resource.name.capitalized)
                .font(.caption)
                .lineLimit(DrawingConstants.lineLimit)
        }
        .padding(DrawingConstants.cellPadding)
        .background(
            RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                .fill(.thinMaterial)
        )
    }
    
    private struct DrawingConstants {
        static let aspectRatio: CGFloat = 1
        static let cornerRadius: CGFloat = 8
        static let lineLimit: Int = 1
        static let cellPadding: CGFloat = 8
    }
}

#Preview {
    PokemonCell(resource: PokemonAPIResource(name: "hello", url: "url"), detail: nil)
}
