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
            if let spriteURL = detail?.sprites.frontDefault,
               let url = URL(string: spriteURL) {
                AsyncImage(url: url) { img in
                    img.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 72, height: 72)
            } else {
                ProgressView()
                    .frame(width: 72, height: 72)
            }
            
            Text(resource.name.capitalized)
                .font(.caption)
        }
        .padding(6)
    }
}

#Preview {
    PokemonCell(resource: PokemonAPIResource(name: "hello", url: "url"), detail: nil)
}
