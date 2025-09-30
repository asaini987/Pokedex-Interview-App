//
//  WelcomeView.swift
//  Pokedex
//
//  Created by Aaditya Saini on 9/30/25.
//

import SwiftUI

struct WelcomeView: View {
    @State private var samplePokemon: [PokemonDetail] = []
    private let api = PokeAPIClient()

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to Pokédex")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                    .padding(.top, DrawingConstants.topPadding)

                Spacer()

                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: DrawingConstants.gridSpacing),
                        count: DrawingConstants.gridColumns
                    ),
                    spacing: DrawingConstants.gridSpacing
                ) {
                    ForEach(samplePokemon, id: \.id) { pokemon in
                        if let sprite = pokemon.sprites.frontDefault,
                           let url = URL(string: sprite) {
                            VStack {
                                CachedAsyncImage(url: url)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: DrawingConstants.cardCornerRadius)
                                    .fill(.thinMaterial)
                                    .shadow(radius: DrawingConstants.cardShadowRadius)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: DrawingConstants.cardCornerRadius)
                                    .stroke(.yellow.opacity(DrawingConstants.opacity),
                                            lineWidth: DrawingConstants.cardBorderWidth)
                            )
                        }
                    }
                }
                .padding(.horizontal, DrawingConstants.horizontalPadding)

                Spacer()

                welcomeButton
            }
            .padding()
            .task {
                await loadSamplePokemon()
            }
        }
        .navigationBarHidden(true)
    }

    private func loadSamplePokemon() async {
        do {
            let response = try await api.fetchPokemonList(
                limit: DrawingConstants.sampleCount,
                offset: DrawingConstants.sampleOffset
            )
            
            var details: [PokemonDetail] = []
            
            for resource in response.results {
                let detail = try await api.fetchPokemonDetail(idOrName: resource.name)
                details.append(detail)
            }
            
            samplePokemon = details
        } catch {
            print("Failed to load sample Pokémon: \(error)")
        }
    }

    @MainActor
    var welcomeButton: some View {
        NavigationLink {
            PokemonGridView()
        } label: {
            Text("See my Pokédex!")
                .padding(DrawingConstants.buttonPadding)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: DrawingConstants.buttonCornerRadius)
                        .foregroundStyle(
                            LinearGradient(colors: [.red, .orange],
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                )
                .padding(.horizontal, DrawingConstants.horizontalPadding)
        }
    }
    
    private struct DrawingConstants {
        static let topPadding: CGFloat = 16
        static let gridColumns: Int = 2
        static let gridSpacing: CGFloat = 20
        static let horizontalPadding: CGFloat = 8
        static let cardCornerRadius: CGFloat = 16
        static let cardShadowRadius: CGFloat = 5
        static let cardBorderWidth: CGFloat = 2
        static let buttonPadding: CGFloat = 12
        static let buttonCornerRadius: CGFloat = 10
        static let opacity: CGFloat = 0.5
        static let sampleCount: Int = 6
        static let sampleOffset: Int = 24
    }
}

#Preview {
    WelcomeView()
}
