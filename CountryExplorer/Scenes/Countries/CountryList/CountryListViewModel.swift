//
//  CountryListViewModel.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/25/25.
//

import Foundation
import Combine
import CoreLocation

protocol CountryListCoordinatorDelegate: AnyObject {
    func showCountryDetail(country: Country)
    func showCountrySearch()
}

class CountryListViewModel: ObservableObject {
    @Published var savedCountries: [Country] = []
    @Published var searchResults: [Country] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSearching = false
    @Published var searchQuery = ""
    
    private let apiService: APIServiceProtocol
    private let locationService: LocationServiceProtocol
    private let storageService: StorageServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var allCountries: [Country] = []
    
    // Coordinator delegate
    weak var coordinatorDelegate: CountryListCoordinatorDelegate?
    
    init(apiService: APIServiceProtocol,
         locationService: LocationServiceProtocol,
         storageService: StorageServiceProtocol,
         coordinatorDelegate: CountryListCoordinatorDelegate? = nil) {
        self.apiService = apiService
        self.locationService = locationService
        self.storageService = storageService
        self.coordinatorDelegate = coordinatorDelegate
        
        setupBindings()
    }
    
    private func setupBindings() {
        storageService.savedCountriesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] countries in
                self?.savedCountries = countries
            }
            .store(in: &cancellables)
        
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.searchCountries(query: query)
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func loadInitialData() async {
        // First load saved countries
        self.savedCountries = storageService.loadSavedCountries()
        
        // Then try to add user's country
        if self.savedCountries.isEmpty {
            await addUserCountry()
        }
        
        // Finally fetch all countries for search
        if allCountries.isEmpty {
            await fetchAllCountries()
        }
    }
    
    @MainActor
    private func addUserCountry() async {
        do {
            // Get user location
            let location = try await locationService.getCurrentLocation()
            let countryCode = try await locationService.getCountryCode(from: location)
            
            // Fetch country data
            let country = try await apiService.fetchCountryByCode(code: countryCode)
            
            // Save to storage
            DispatchQueue.main.async {
                try? self.storageService.saveCountry(country)
            }
        } catch LocationError.permissionDenied {
            await addDefaultCountry()
        } catch {
            await addDefaultCountry()
            self.errorMessage = "Failed to get location: \(error.localizedDescription)"
        }
    }
    
    private func addDefaultCountry() async {
        do {
            let country = try await apiService.fetchCountryByCode(code: LocationConstants.defaultCountryCode)
            DispatchQueue.main.async {
                try? self.storageService.saveCountry(country)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to add default country: \(error.localizedDescription)"
            }
        }
    }
    
    private func fetchAllCountries() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        do {
            let countries = try await apiService.fetchAllCountries()
            DispatchQueue.main.async {
                self.allCountries = countries
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to fetch countries: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func didReachMaxCountries() -> Bool {
        if savedCountries.count >= StorageConstants.maxSavedCountries {
            errorMessage = "You can only save up to \(StorageConstants.maxSavedCountries) countries."
            return false
        } else {
            return true
        }
    }
    
    func searchCountries(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        let filteredCountries = allCountries.filter {
            $0.name.lowercased().contains(query.lowercased())
        }
        
        searchResults = filteredCountries
    }
    
    func saveCountry(_ country: Country) {
        guard didReachMaxCountries() else {return}

        do {
            try storageService.saveCountry(country)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func removeCountry(_ country: Country) {
        storageService.removeCountry(country)
    }
    
    func isCountrySaved(_ country: Country) -> Bool {
        return storageService.isCountrySaved(country)
    }
    
    // MARK: - Coordinator Actions
    
    func didSelectCountry(_ country: Country) {
        coordinatorDelegate?.showCountryDetail(country: country)
    }
    
    func didTapAddCountry() {
        guard didReachMaxCountries() else {return}
        
        coordinatorDelegate?.showCountrySearch()
    }
}
