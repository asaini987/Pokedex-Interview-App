//
//  PokemonGridView.swift
//  Pokedex
//
//  Created by Aaditya Saini on 9/27/25.
//

import SwiftUI

struct PokemonGridView: View {
    @State private var viewModel = PokemonGridViewModel()
    
    private let columns = [
        GridItem(.adaptive(minimum: DrawingConstants.cellMin, maximum: DrawingConstants.cellMax), spacing: DrawingConstants.cellSpacing)
    ]

    var body: some View {
        NavigationStack {
            VStack {
                SelectedPokemonView(detail: viewModel.selectedDetail)
                    .padding(.bottom)

                ScrollView {
                    switch viewModel.pokeListState {
                    case .idle:
                        Text("Welcome to Pokédex")
                            .foregroundStyle(.secondary)
                    case .loading:
                        ProgressView()
                            .scaleEffect(DrawingConstants.loadingScale)
                    case .failed(let err):
                        Text("\(err.message)").foregroundStyle(.red)
                    case .success(let pokemons):
                        LazyVGrid(columns: columns, spacing: DrawingConstants.gridHorizontalSpacing) {
                            ForEach(pokemons) { resource in
                                PokemonCell(resource: resource,
                                            detail: viewModel.details[resource.name])
                                    .task {
                                        await viewModel.loadDetail(for: resource)
                                    }
                                    .onTapGesture {
                                        viewModel.selectPokemon(resource)
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Pokédex")
            .task {
                await viewModel.loadInitialPokemons()
            }
        }
    }
    
    private struct DrawingConstants {
        static let cellMin: CGFloat = 100
        static let cellMax: CGFloat = 160
        static let cellSpacing: CGFloat = 12
        static let loadingScale: CGFloat = 1.3
        static let gridHorizontalSpacing: CGFloat = 12
    }
}

#Preview {
    PokemonGridView()
}
