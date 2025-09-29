//
//  PokedexModels.swift
//  Pokedex
//
//  Created by Aaditya Saini on 9/26/25.
//

import Foundation

struct PokemonListResponse: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonAPIResource]
}

struct PokemonAPIResource: Decodable, Equatable, Identifiable {
    let name: String
    let url: String
    
    var id: String {
        name
    }
}

struct PokemonDetail: Decodable, Equatable {
    let id: Int
    let name: String
    let sprites: Sprites
    
    struct Sprites: Decodable, Equatable {
        let frontDefault: String?
        
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
    }
}

enum PokemonListState: Equatable {
    case loading
    case success([PokemonAPIResource], canLoadMore: Bool)
}

enum PokeAPIError: Error, Equatable {
    case badURL
    case badResponse(statusCode: Int)
    case decodingError
    case networkError(String)
    
    var message: String {
        switch self {
        case .badURL:
            return "Invalid request URL."
        case .badResponse(let statusCode):
            return "Server responded with code \(statusCode)."
        case .decodingError:
            return "Failed to process server data."
        case .networkError(let description):
            return "Network issue: \(description)"
        }
    }
}
