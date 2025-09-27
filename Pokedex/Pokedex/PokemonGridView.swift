//
//  PokemonGridView.swift
//  Pokedex
//
//  Created by Aaditya Saini on 9/27/25.
//

import SwiftUI

struct PokemonGridView: View {
    @State private var viewModel = PokemonGridViewModel()
    private let columns = [GridItem(.adaptive(minimum: 80), spacing: 12)]

    var body: some View {
        NavigationStack {
            VStack {
                SelectedPokemonView(detail: viewModel.selectedDetail)
                
                ScrollView {
                    switch viewModel.pokeListState {
                    case .idle:
                        Text("Welcome to Pokédex")
                            .foregroundStyle(.secondary)
                    case .loading:
                        ProgressView()
                            .scaleEffect(1.3)
                    case .failed(let err):
                        Text("\(err.message)")
                            .foregroundStyle(.red)
                    case .success(let pokemons):
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(pokemons) { resource in
                                PokemonCell(resource: resource, detail: viewModel.details[resource.name])
                                    .task {
                                        await viewModel.loadDetail(for: resource) // lazy load sprite
                                    }
                                    .onTapGesture {
                                        viewModel.selectPokemon(resource)
                                    }
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                }
            }
            .navigationTitle("Pokédex")
            .task {
                await viewModel.loadInitialPokemons()
            }
        }
    }
}
#Preview {
    PokemonGridView()
}
