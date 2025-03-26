//
//  CountryRequest.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/25/25.
//

import Foundation

enum CountryRequest {
    struct AllCountries: NetworkRequest {
        typealias Response = [Country]
        
        var url: URL {
            get throws {
                guard let url = URL(string: APIConstants.baseURL + APIConstants.allCountriesEndpoint) else {
                    throw APIError.invalidURL
                }
                return url
            }
        }
        
        func decode(_ data: Data) throws -> [Country] {
            let decoder = JSONDecoder()
            return try decoder.decode([Country].self, from: data)
        }
    }
    
    struct CountryByCode: NetworkRequest {
        typealias Response = Country
        
        let code: String
        
        var url: URL {
            get throws {
                guard let url = URL(string: APIConstants.baseURL + APIConstants.countryByCodeEndpoint + code) else {
                    throw APIError.invalidURL
                }
                return url
            }
        }
        
        func decode(_ data: Data) throws -> Country {
            let decoder = JSONDecoder()
            return try decoder.decode(Country.self, from: data)
        }
    }
}
