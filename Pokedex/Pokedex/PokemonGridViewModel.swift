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
        case let (.success(lhsList, lhsCanLoad), .success(rhsList, rhsCanLoad)):
            return lhsList == rhsList && lhsCanLoad == rhsCanLoad
        default:
            return false
        }
    }
    
    case idle
    case loading
    case failed(PokeAPIError)
    case success([PokemonAPIResource], canLoadMore: Bool)
}

@Observable
final class PokemonGridViewModel {
    private(set) var pokeListState: PokemonListState = .idle
    private(set) var details: [String: PokemonDetail] = [:]  // cache by name
    private(set) var selectedDetail: PokemonDetail?
    
    private let api = PokeAPIClient()
    private var offset: Int = 0
    private let limit: Int = 20
    private var isLoadingMore = false
    
    func loadInitialPokemons() async {
        offset = 0
        
        await MainActor.run {
            pokeListState = .loading
        }
        
        await fetchMorePokemons(reset: true)
    }
    
    func fetchMorePokemons(reset: Bool = false) async {
        guard !isLoadingMore else {
            return
        }
        isLoadingMore = true
        
        do {
            let response = try await api.fetchPokemonList(limit: limit, offset: offset)
            offset += limit
            
            let canLoadMore = (response.results.count == limit)
            
            await MainActor.run {
                if reset {
                    pokeListState = .success(response.results, canLoadMore: canLoadMore)
                } else if case .success(let existing, _) = pokeListState {
                    pokeListState = .success(existing + response.results, canLoadMore: canLoadMore)
                } else {
                    pokeListState = .success(response.results, canLoadMore: canLoadMore)
                }
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
        
        isLoadingMore = false
    }
    
    func loadDetail(for pokemonResource: PokemonAPIResource) async {
        if details[pokemonResource.name] != nil {
            return
        }
        
        do {
            let detail = try await api.fetchPokemonDetail(idOrName: pokemonResource.name)
            await MainActor.run {
                details[pokemonResource.name] = detail
            }
        } catch {
            print("Failed to fetch detail for \(pokemonResource.name)") // TODO: add more robust error handling
        }
    }
    
    func selectPokemon(_ pokemonResource: PokemonAPIResource) {
        if let cached = details[pokemonResource.name] {
            selectedDetail = cached
        }
    }
}


