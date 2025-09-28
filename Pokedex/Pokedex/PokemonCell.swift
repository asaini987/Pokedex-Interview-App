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
            AsyncImage(
                url: detail?.sprites.frontDefault.flatMap(URL.init)
            ) { img in
                img.resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } placeholder: {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .aspectRatio(DrawingConstants.aspectRatio, contentMode: .fit)
            
            Text(resource.name.capitalized)
                .font(.caption)
                .lineLimit(DrawingConstants.lineLimit)
                .padding(.bottom)
        }
        .background(
            RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
                .fill(.thinMaterial)
        )
    }
    
    private struct DrawingConstants {
        static let aspectRatio: CGFloat = 1
        static let cornerRadius: CGFloat = 8
        static let lineLimit: Int = 1
    }
}

#Preview {
    PokemonCell(resource: PokemonAPIResource(name: "hello", url: "url"), detail: nil)
}
