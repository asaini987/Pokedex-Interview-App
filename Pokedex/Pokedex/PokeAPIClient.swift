//
//  PokeAPIClient.swift
//  Pokedex
//
//  Created by Aaditya Saini on 9/27/25.
//

import Foundation

struct PokeAPIClient {
    private let baseUrl = "https://pokeapi.co/api/v2/pokemon"
    
    func fetchPokemonList(limit: Int = 20, offset: Int = 0) async throws -> PokemonListResponse {
        var components = URLComponents(string: baseUrl)
        components?.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        
        guard let url = components?.url else {
            throw PokeAPIError.badURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw PokeAPIError.badResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            
            return try JSONDecoder().decode(PokemonListResponse.self, from: data)
        } catch let error as DecodingError {
            throw PokeAPIError.decodingError
        } catch {
            throw PokeAPIError.networkError(error.localizedDescription)
        }
    }
    
    func fetchPokemonDetail(idOrName: String) async throws -> PokemonDetail {
        guard let url = URL(string: "\(baseUrl)/\(idOrName)/") else {
            throw PokeAPIError.badURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw PokeAPIError.badResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
            }
            
            return try JSONDecoder().decode(PokemonDetail.self, from: data)
        } catch let error as DecodingError {
            throw PokeAPIError.decodingError
        } catch {
            throw PokeAPIError.networkError(error.localizedDescription)
        }
    }
}
