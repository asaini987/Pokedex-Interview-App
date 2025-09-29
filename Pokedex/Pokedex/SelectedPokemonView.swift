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
            if let detail {
                if let spriteURL = detail.sprites.frontDefault,
                   let url = URL(string: spriteURL) {
                    AsyncImage(url: url) { img in
                        img.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .aspectRatio(DrawingConstants.aspectRatio, contentMode: .fit)
                    .shadow(radius: DrawingConstants.shadowRadius)
                } else {
                    Image(systemName: "questionmark.square.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                        .aspectRatio(DrawingConstants.aspectRatio, contentMode: .fit)
                        .shadow(radius: DrawingConstants.shadowRadius)
                }
                
                Text(detail.name.capitalized)
                    .font(.title2.weight(.semibold))

            } else {
                VStack {
                    pokeBall
                        .aspectRatio(DrawingConstants.aspectRatio, contentMode: .fit)
                    Text("Tap a Pokémon")
                        .foregroundStyle(.secondary)
                        .padding(.top)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: DrawingConstants.minHeight, maxHeight: DrawingConstants.maxHeight)
        .padding()
    }
    
    var pokeBall: some View {
        ZStack {
            Circle()
                .fill(.red)
            
            Circle()
                .trim(from: DrawingConstants.trimStart, to: DrawingConstants.trimEnd)
                .fill(.white)
                .rotationEffect(.degrees(DrawingConstants.rotationEffect))
            
            Circle()
                .stroke(.black, lineWidth: DrawingConstants.outerRingLineWidth)
            
            Circle()
                .fill(.white)
                .overlay(
                    Circle()
                        .stroke(.black, lineWidth: DrawingConstants.innerRingLineWidth)
                )
                .scaleEffect(DrawingConstants.scaleEffect)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private struct DrawingConstants {
        // Pokemon image constants
        static let aspectRatio: CGFloat = 1
        static let shadowRadius: CGFloat = 6
        static let minHeight: CGFloat = 220
        static let maxHeight: CGFloat = 240
        
        // Pokeball constants
        static let rotationEffect: Double = 180
        static let outerRingLineWidth: CGFloat = 4
        static let innerRingLineWidth: CGFloat = 12
        static let scaleEffect: CGFloat = 0.3
        static let trimStart: CGFloat = 0.5
        static let trimEnd: CGFloat = 1.0
    }
}

#Preview {
    SelectedPokemonView(detail: nil)
}
