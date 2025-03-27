//
//  MockAPIService.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/26/25.
//

import Foundation
import CoreLocation
@testable import CountryExplorer

// MARK: - Mock API Service

class MockAPIService: APIServiceProtocol {
    var shouldFail = false
    var mockedCountries: [Country] = []
    var mockedCountry: Country?
    
    func fetchAllCountries() async throws -> [Country] {
        if shouldFail {
            throw APIError.networkError(NSError(domain: "test", code: 0))
        }
        return mockedCountries
    }
    
    func fetchCountryByCode(code: String) async throws -> Country {
        if shouldFail {
            throw APIError.networkError(NSError(domain: "test", code: 0))
        }
        guard let country = mockedCountry else {
            throw APIError.noData
        }
        return country
    }
}
