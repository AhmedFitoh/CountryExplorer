//
//  CountryListViewModelTests.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/26/25.
//

import XCTest
import Combine
@testable import CountryExplorer

final class CountryListViewModelTests: XCTestCase {
    var viewModel: CountryListViewModel!
    var mockAPIService: MockAPIService!
    var mockLocationService: MockLocationService!
    var mockStorageService: MockStorageService!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        
        mockAPIService = MockAPIService()
        mockLocationService = MockLocationService()
        mockStorageService = MockStorageService()
        
        viewModel = CountryListViewModel(
            apiService: mockAPIService,
            locationService: mockLocationService,
            storageService: mockStorageService
        )
        
        // Set up mock data
        let egCurrency = Currency(code: "EGP", name: "Egyptian pound", symbol: "£")
        let egCountry = Country(
            name: "Egypt",
            capital: "Cairo.",
            currencies: [egCurrency],
            flag: "🇪🇬",
            alpha2Code: "EG",
            alpha3Code: "EGY"
        )
        
        let ukCurrency = Currency(code: "GBP", name: "British Pound", symbol: "£")
        let ukCountry = Country(
            name: "United Kingdom",
            capital: "London",
            currencies: [ukCurrency],
            flag: "🇬🇧",
            alpha2Code: "GB",
            alpha3Code: "GBR"
        )
        
        mockAPIService.mockedCountries = [egCountry, ukCountry]
        mockAPIService.mockedCountry = egCountry
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPIService = nil
        mockLocationService = nil
        mockStorageService = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testInitialDataLoading() async {
        // Setup expectations
        let countriesLoadedExpectation = expectation(description: "Countries loaded")
        let loadingCompletedExpectation = expectation(description: "Loading completed")
        
        // Monitor savedCountries changes
        viewModel.$savedCountries
            .dropFirst()
            .sink { countries in
                if !countries.isEmpty {
                    countriesLoadedExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Monitor loading state changes
        var loadingObserved = false
        viewModel.$isLoading
            .sink { isLoading in
                if isLoading {
                    loadingObserved = true
                } else if loadingObserved {
                    loadingCompletedExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Act
        await MainActor.run {
            Task {
                await viewModel.loadInitialData()
            }
        }
        
        // Wait for expectations
        await fulfillment(of: [countriesLoadedExpectation, loadingCompletedExpectation], timeout: 3.0)

        // Assert
        XCTAssertEqual(viewModel.savedCountries.count, 1, "Should have one country (user's location)")
        XCTAssertEqual(viewModel.savedCountries.first?.alpha2Code, "EG", "Should be EG country")
        XCTAssertFalse(viewModel.isLoading, "Loading should be completed")
        XCTAssertEqual(mockStorageService.countries.count, 1, "Storage should have one country")
    }
    func testLocationPermissionDenied() async {
        // Arrange
        mockLocationService.shouldFailLocation = true
        
        // Act
        await viewModel.loadInitialData()
        
        // Assert
        XCTAssertEqual(viewModel.savedCountries.count, 1, "Should fallback to default country")
        XCTAssertEqual(viewModel.savedCountries.first?.alpha2Code, LocationConstants.defaultCountryCode)
    }
    
//    func testSearchFunctionality() async {
//        // Arrange
//        await viewModel.loadInitialData()
//        
//        // Act
//        viewModel.searchQuery = "United"
//        
//        // Wait for debounce
//        let expectation = XCTestExpectation(description: "Search results updated")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            expectation.fulfill()
//        }
//        await fulfillment(of: [expectation], timeout: 2.0)
//        
//        // Assert
//        XCTAssertEqual(viewModel.searchResults.count, 1, "Should find UK")
//        XCTAssertTrue(viewModel.searchResults.contains { $0.name == "United Kingdom" })
//    }
    
    func testSearchFunctionality() async {
        await viewModel.loadInitialData()
        
        // Act
        await MainActor.run {
            viewModel.searchQuery = "United"
        }

        let searchExpectation = expectation(description: "Search results updated")

        viewModel.$searchResults
            .dropFirst()
            .sink { results in
                if results.contains(where: { $0.name == "United Kingdom" }) {
                    searchExpectation.fulfill()
                }
            }
            .store(in: &cancellables)

        await fulfillment(of: [searchExpectation], timeout: 2.0)

        // Assert
        XCTAssertEqual(viewModel.searchResults.count, 1, "Should find UK")
    }

    
    func testAddingCountry() async {
        // Arrange
        await viewModel.loadInitialData()
        let ukCountry = mockAPIService.mockedCountries[1]
        
        // Create expectation for savedCountries update
        let expectation = XCTestExpectation(description: "Country added")
        
        // Setup publisher monitoring
        var cancellables = Set<AnyCancellable>()
        let initialCount = viewModel.savedCountries.count
        
        viewModel.$savedCountries
            .dropFirst() // Skip current value
            .sink { countries in
                if countries.count > initialCount {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Act - ensure on main thread
        await MainActor.run {
            viewModel.saveCountry(ukCountry)
        }
        
        // Wait for the update
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // Assert
        XCTAssertEqual(viewModel.savedCountries.count, initialCount + 1, "Should have one more country")
        XCTAssertTrue(viewModel.isCountrySaved(ukCountry), "UK should be saved")
        
        // Clean up
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    func testRemovingCountry() async {
        // Arrange
        await viewModel.loadInitialData()
        
        // Make sure we have at least one country
        XCTAssertFalse(viewModel.savedCountries.isEmpty, "Should have at least one country loaded")
        let egCountry = viewModel.savedCountries.first!
        
        // Create expectation for country removal
        let expectation = XCTestExpectation(description: "Country removed")
        
        // Monitor changes to savedCountries
        var cancellables = Set<AnyCancellable>()
        viewModel.$savedCountries
            .dropFirst() // Skip current value
            .sink { countries in
                if !countries.contains(where: { $0 == egCountry }) {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Act - ensure on main thread
        await MainActor.run {
            viewModel.removeCountry(egCountry)
        }
        
        // Wait for removal to be reflected in savedCountries
        await fulfillment(of: [expectation], timeout: 2.0)
        
        // Assert
        XCTAssertFalse(viewModel.savedCountries.contains(where: { $0 == egCountry }), "EG should not be in saved countries")
        XCTAssertFalse(viewModel.isCountrySaved(egCountry), "isCountrySaved should return false")
        
        // Clean up
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    func testCountryLimit() async {
        // Arrange
        mockStorageService.limitReached = true
        await viewModel.loadInitialData()
        let ukCountry = mockAPIService.mockedCountries[1]
        
        // Capture initial state
        let initialCount = viewModel.savedCountries.count
        
        // Create expectations
        let errorExpectation = XCTestExpectation(description: "Error message set")
        
        // Setup monitoring for error message
        var cancellables = Set<AnyCancellable>()
        viewModel.$errorMessage
            .dropFirst() // Skip initial nil value
            .compactMap { $0 } // Only non-nil values
            .sink { _ in
                errorExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Act - ensure on main thread
        await MainActor.run {
            viewModel.saveCountry(ukCountry)
        }
        
        // Wait for error message to be set
        await fulfillment(of: [errorExpectation], timeout: 1.0)
        
        // Verify error was set
        XCTAssertNotNil(viewModel.errorMessage, "Error message should be set")
        
        // Assert countries weren't changed
        XCTAssertEqual(viewModel.savedCountries.count, initialCount, "Should still have the same number of countries")
        XCTAssertFalse(viewModel.isCountrySaved(ukCountry), "UK should not be saved")
        
        // Clean up
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
