//
//  PokemonGridViewModel.swift
//  Pokedex
//
//  Created by Aaditya Saini on 9/27/25.
//

import Foundation
import Observation

enum PokemonListState: Equatable {
    static func == (lhs: PokemonListState, rhs: PokemonListState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case let (.failed(lhsErr), .failed(rhsErr)):
            return lhsErr == rhsErr
        case let (.success(lhsList), .success(rhsList)):
            return lhsList == rhsList
        default:
            return false
        }
    }
    
    case idle
    case loading
    case failed(PokeAPIError)
    case success([PokemonAPIResource])
}

@Observable
final class PokemonGridViewModel {
    private(set) var pokeListState: PokemonListState = .idle
    private(set) var details: [String: PokemonDetail] = [:]  // cache by name
    private(set) var selectedDetail: PokemonDetail?
    
    private let api = PokeAPIClient()
    
    func loadInitialPokemons() async {
        await MainActor.run {
            pokeListState = .loading
        }
        
        do {
            let response = try await api.fetchPokemonList(limit: 200, offset: 0)
            
            await MainActor.run {
                pokeListState = .success(response.results)
            }
        } catch let error as PokeAPIError {
            await MainActor.run {
                pokeListState = .failed(error)
            }
        } catch {
            await MainActor.run {
                pokeListState = .failed(.networkError(error.localizedDescription))
            }
        }
    }
    
    func loadDetail(for pokemonResource: PokemonAPIResource) async {
        if details[pokemonResource.name] != nil { // already cached
            return
        }
        
        do {
            let detail = try await api.fetchPokemonDetail(idOrName: pokemonResource.name)
            
            await MainActor.run {
                details[pokemonResource.name] = detail
            }
        } catch {
            print("Failed to fetch image for \(pokemonResource.name)") // TODO: add more robust error handling
        }
    }
    
    func selectPokemon(_ pokemonResource: PokemonAPIResource) {
        if let cached = details[pokemonResource.name] {
            selectedDetail = cached
        }
    }
}
