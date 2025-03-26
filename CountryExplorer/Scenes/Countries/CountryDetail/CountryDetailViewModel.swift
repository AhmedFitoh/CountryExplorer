//
//  CountryDetailViewModel.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/26/25.
//

import Foundation
import Combine

class CountryDetailViewModel: ObservableObject {
    @Published var country: Country
    @Published var isSaved: Bool = false
    
    private let storageService: StorageServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(country: Country, storageService: StorageServiceProtocol) {
        self.country = country
        self.storageService = storageService
        self.isSaved = storageService.isCountrySaved(country)
        
        setupBindings()
    }
    
    private func setupBindings() {
        storageService.savedCountriesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countries in
                guard let self = self else { return }
                self.isSaved = countries.contains(self.country)
            }
            .store(in: &cancellables)
    }
    
    func toggleSaved() {
        if isSaved {
            storageService.removeCountry(country)
        } else {
            do {
                try storageService.saveCountry(country)
            } catch {
                print("Error saving country: \(error)")
            }
        }
    }
    
    var formattedCurrencies: String {
        guard let currencies = country.currencies, !currencies.isEmpty else {
            return "No currency information"
        }
        
        return currencies.map { currency in
            let symbol = currency.symbol != nil ? " (\(currency.symbol!))" : ""
            return "\(currency.name)\(symbol)"
        }.joined(separator: ", ")
    }
    
    var capital: String {
        return country.capital ?? "No capital information"
    }
}
