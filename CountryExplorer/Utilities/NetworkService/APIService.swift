//
//  APIService.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/25/25.
//

import Foundation

protocol APIServiceProtocol {
    func fetchAllCountries() async throws -> [Country]
    func fetchCountryByCode(code: String) async throws -> Country
}

class APIService: APIServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchAllCountries() async throws -> [Country] {
        let request = CountryRequest.AllCountries()
        return try await networkService.execute(request)
    }
    
    func fetchCountryByCode(code: String) async throws -> Country {
        let request = CountryRequest.CountryByCode(code: code)
        return try await networkService.execute(request)
    }
}
