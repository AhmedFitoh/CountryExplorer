//
//  StorageServiceProtocol.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/25/25.
//

import Foundation
import Combine

protocol StorageServiceProtocol {
    var savedCountriesPublisher: Published<[Country]>.Publisher { get }
    func saveCountry(_ country: Country) throws
    func loadSavedCountries() -> [Country]
    func removeCountry(_ country: Country)
    func isCountrySaved(_ country: Country) -> Bool
}

class StorageService: StorageServiceProtocol {
    @Published private var savedCountries: [Country] = []
    
    var savedCountriesPublisher: Published<[Country]>.Publisher { $savedCountries }
    
    init() {
        savedCountries = loadSavedCountries()
    }
    
    func saveCountry(_ country: Country) throws {
        // Check if country already exists
        if isCountrySaved(country) {
            throw StorageError.countryAlreadyExists
        }
        
        // Check if limit reached
        if savedCountries.count >= StorageConstants.maxSavedCountries {
            throw StorageError.countryLimitReached
        }
        
        savedCountries.append(country)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(savedCountries)
            UserDefaults.standard.set(data, forKey: StorageConstants.savedCountriesKey)
        } catch {
            throw StorageError.saveFailed
        }
    }
    
    func loadSavedCountries() -> [Country] {
        guard let data = UserDefaults.standard.data(forKey: StorageConstants.savedCountriesKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Country].self, from: data)
        } catch {
            print("Error loading saved countries: \(error)")
            return []
        }
    }
    
    func removeCountry(_ country: Country) {
        savedCountries.removeAll { $0 == country }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(savedCountries)
            UserDefaults.standard.set(data, forKey: StorageConstants.savedCountriesKey)
        } catch {
            print("Error removing country: \(error)")
        }
    }
    
    func isCountrySaved(_ country: Country) -> Bool {
        return savedCountries.contains(country)
    }
}
