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
    let results: [PokemonListItem]
}

struct PokemonListItem: Decodable, Equatable {
    let name: String
    let url: String
}

struct PokemonDetail: Decodable {
    let id: Int
    let name: String
    let sprites: [Sprites]
    
    struct Sprites: Decodable {
        let frontDefault: String?
        
        enum CodingKeys: String, CodingKey {
            case frontDefault = "front_default"
        }
    }
}


