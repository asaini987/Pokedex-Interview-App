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
    private(set) var details: [String: PokemonDetail] = [:]  // cache URLs by name
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
            
            lastError = nil // clear on success
            
            if reset {
                pokeListState = .success(response.results, canLoadMore: canLoadMore)
            } else if case .success(let existing, _) = pokeListState {
                pokeListState = .success(existing + response.results, canLoadMore: canLoadMore)
            } else {
                pokeListState = .success(response.results, canLoadMore: canLoadMore)
            }
        } catch let err as PokeAPIError {
            lastError = err
        } catch {
            lastError = .networkError(error.localizedDescription)
        }
    }
    
    func loadDetail(for pokemonResource: PokemonAPIResource) async {
        if details[pokemonResource.name] != nil { return }
        
        do {
            let detail = try await api.fetchPokemonDetail(idOrName: pokemonResource.name)
            details[pokemonResource.name] = detail
        } catch let error as PokeAPIError {
            if case .networkError(let msg) = error, msg == "cancelled" {
                return // ignore cancelled requests
            }
            print("Failed for \(pokemonResource.name): \(error.message)")
        } catch {
            print("Failed for \(pokemonResource.name): \(error.localizedDescription)")
        }
    }
    
    func selectPokemon(_ pokemonResource: PokemonAPIResource) {
        if let cached = details[pokemonResource.name] {
            selectedDetail = cached
        }
    }
}
