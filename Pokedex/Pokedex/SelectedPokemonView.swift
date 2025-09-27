//
//  SelectedPokemonView.swift
//  Pokedex
//
//  Created by Aaditya Saini on 9/27/25.
//

import SwiftUI

struct SelectedPokemonView: View {
    let detail: PokemonDetail?
    
    var body: some View {
        VStack {
            if let detail, let spriteURL = detail.sprites.frontDefault,
               let url = URL(string: spriteURL) {
                AsyncImage(url: url) { img in
                    img.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 160, height: 160)
                .shadow(radius: 6)
                
                Text(detail.name.capitalized)
                    .font(.title2.weight(.semibold))
            } else {
                Text("Tap a Pokémon")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}

#Preview {
    SelectedPokemonView(detail: nil)
}
