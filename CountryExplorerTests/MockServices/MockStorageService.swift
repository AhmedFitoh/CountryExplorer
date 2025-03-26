//
//  MockStorageService.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/26/25.
//


import Foundation
import CoreLocation
@testable import CountryExplorer

// MARK: - Mock Storage Service

class MockStorageService: StorageServiceProtocol {
    @Published var countries: [Country] = []
    
    var savedCountriesPublisher: Published<[Country]>.Publisher { $countries }
    
    var shouldFailOnSave = false
    var limitReached = false
    
    func saveCountry(_ country: Country) throws {
        if shouldFailOnSave {
            throw StorageError.saveFailed
        }
        
        if isCountrySaved(country) {
            throw StorageError.countryAlreadyExists
        }
        
        if limitReached || countries.count >= StorageConstants.maxSavedCountries {
            throw StorageError.countryLimitReached
        }
        
        countries.append(country)
    }
    
    func loadSavedCountries() -> [Country] {
        return countries
    }
    
    func removeCountry(_ country: Country) {
        countries.removeAll { $0 == country }
    }
    
    func isCountrySaved(_ country: Country) -> Bool {
        return countries.contains { $0 == country }
    }
}
