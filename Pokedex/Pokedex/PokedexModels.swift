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

struct PokemonDetail: Decodable {
    let id: Int
    let name: String
    let sprites: Sprites
    
    struct Sprites: Decodable {
        let frontDefault: String?
        
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
    }
}


