//
//  PokemonGridViewModel.swift
//  Pokedex
//
//  Created by Aaditya Saini on 9/27/25.
//

import Foundation
import Observation

@Observable
@MainActor
final class PokemonGridViewModel {
    private(set) var pokeListState: PokemonListState = .loading
    private(set) var lastError: PokeAPIError? = nil
    private(set) var details: [String: PokemonDetail] = [:]  // store image URLs by name
    private(set) var selectedDetail: PokemonDetail? = nil
    
    private let api = PokeAPIClient()
    
    private var offset: Int = 0
    private let limit: Int = 20
    private var isLoadingMore = false
    
    func loadInitialPokemons() async {
        offset = 0
        pokeListState = .loading
        await fetchMorePokemons(reset: true)
    }
    
    /// Fetches the next page of Pokémon from the PokeAPI and updates the grid state.
    ///
    /// This method handles pagination by advancing the `offset` and using `limit`
    /// to request more results. When `reset` is `true`, the current list is replaced
    /// with a fresh page. Otherwise, new results are appended to the existing list.
    ///
    /// - Parameters:
    ///    - reset: A Boolean value that determines whether to reset the list before
    ///     fetching more Pokémon
    ///
    /// - Returns: Void. The function updates `pokeListState` and `lastError`.
    func fetchMorePokemons(reset: Bool = false) async {
        guard !isLoadingMore else {
            return
        }
        
        isLoadingMore = true
        
        defer {
            isLoadingMore = false
        }
        
        do {
            let response = try await api.fetchPokemonList(limit: limit, offset: offset)
            offset += limit
            let canLoadMore = response.results.count == limit
            
            lastError = nil // clear error on success
            
            if reset {
                pokeListState = .success(response.results, canLoadMore: canLoadMore)
            } else if case .success(let existing, _) = pokeListState {
                pokeListState = .success(existing + response.results, canLoadMore: canLoadMore)
            } else {
                pokeListState = .success(response.results, canLoadMore: canLoadMore)
            }
        } catch let err as PokeAPIError {
            if case .networkError(let msg) = err, msg == "cancelled" {
                return
            }
            lastError = err
        } catch {
            lastError = .networkError(error.localizedDescription)
        }
    }
    
    /// Fetches and caches detail data for a Pokémon if not already loaded.
    ///
    /// - Parameters:
    ///   - pokemonResource: The resource describing the Pokémon.
    ///
    /// - Returns: Void. Updates the `details` dictionary.
    ///
    func loadDetail(for pokemonResource: PokemonAPIResource) async {
        if details[pokemonResource.name] != nil {
            return
        }
        
        do {
            let detail = try await api.fetchPokemonDetail(idOrName: pokemonResource.name)
            details[pokemonResource.name] = detail
        } catch {
            if let apiError = error as? PokeAPIError {
                if case .networkError(let msg) = apiError, msg == "cancelled" {
                    return
                }
            }
        }
    }
    
    // MARK: User Intent(s)
    func selectPokemon(_ pokemonResource: PokemonAPIResource) {
        if let cached = details[pokemonResource.name] {
            selectedDetail = cached
        }
    }
}
