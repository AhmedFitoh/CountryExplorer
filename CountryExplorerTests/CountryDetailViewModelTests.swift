//
//  CountryDetailViewModelTests.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/26/25.
//

import XCTest
import Combine
@testable import CountryExplorer

final class CountryDetailViewModelTests: XCTestCase {
    var viewModel: CountryDetailViewModel!
    var mockStorageService: MockStorageService!
    var testCountry: Country!
    
    override func setUp() {
        super.setUp()
        
        mockStorageService = MockStorageService()
        
        // Set up test country
        
        let egCurrency = Currency(code: "EGP", name: "Egyptian pound", symbol: "£")
        testCountry = Country(
            name: "Egypt",
            capital: "Cairo.",
            currencies: [egCurrency],
            flag: "🇪🇬",
            alpha2Code: "EG",
            alpha3Code: "EGY"
        )
        
        viewModel = CountryDetailViewModel(
            country: testCountry,
            storageService: mockStorageService
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockStorageService = nil
        testCountry = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Assert
        XCTAssertEqual(viewModel.country.name, "Egypt")
        XCTAssertFalse(viewModel.isSaved, "Country should not be saved initially")
    }
    
    func testToggleSave() {
        // Create expectations for the publisher
        let saveExpectation = XCTestExpectation(description: "Country saved")
        let removeExpectation = XCTestExpectation(description: "Country removed")
        
        // Setup state tracking
        var savedStateReached = false
        
        // Setup cancellable to monitor isSaved changes
        var cancellables = Set<AnyCancellable>()
        viewModel.$isSaved
            .dropFirst() // Skip initial value
            .sink { isSaved in
                if isSaved && !savedStateReached {
                    savedStateReached = true
                    saveExpectation.fulfill()
                } else if !isSaved && savedStateReached {
                    removeExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Act
        viewModel.toggleSaved()
        
        // Wait for save to complete
        wait(for: [saveExpectation], timeout: 1.0)
        
        // Assert after save
        XCTAssertTrue(viewModel.isSaved, "Country should be saved after toggle")
        XCTAssertTrue(mockStorageService.isCountrySaved(testCountry), "Country should be in storage")
        
        // Act again
        viewModel.toggleSaved()
        
        // Wait for remove to complete
        wait(for: [removeExpectation], timeout: 1.0)
        
        // Assert after remove
        XCTAssertFalse(viewModel.isSaved, "Country should not be saved after second toggle")
        XCTAssertFalse(mockStorageService.isCountrySaved(testCountry), "Country should not be in storage")
        
        // Clean up
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    func testFormattedCurrencies() {
        // Assert
        XCTAssertEqual(viewModel.formattedCurrencies, "Egyptian pound (£)")
        
        // Change the test country to have multiple currencies
        let euro = Currency(code: "EUR", name: "Euro", symbol: "€")
        let multiCurrencyCountry = Country(
            name: "Test Country",
            capital: "Test Capital",
            currencies: [
                Currency(code: "USD", name: "United States Dollar", symbol: "$"),
                euro
            ],
            flag: "🏳️",
            alpha2Code: "TC",
            alpha3Code: "TCY"
        )
        
        viewModel = CountryDetailViewModel(
            country: multiCurrencyCountry,
            storageService: mockStorageService
        )
        
        // Assert
        XCTAssertEqual(viewModel.formattedCurrencies, "United States Dollar ($), Euro (€)")
    }
    
    func testNoCurrencies() {
        // Arrange
        let noCurrencyCountry = Country(
            name: "Test Country",
            capital: "Test Capital",
            currencies: nil,
            flag: "🏳️",
            alpha2Code: "TC",
            alpha3Code: "TCY"
        )
        
        viewModel = CountryDetailViewModel(
            country: noCurrencyCountry,
            storageService: mockStorageService
        )
        
        // Assert
        XCTAssertEqual(viewModel.formattedCurrencies, "No currency information")
    }
    
    func testCapital() {
        // Assert
        XCTAssertEqual(viewModel.capital, "Cairo.")
        
        // Test with no capital
        let noCapitalCountry = Country(
            name: "Test Country",
            capital: nil,
            currencies: nil,
            flag: "🏳️",
            alpha2Code: "TC",
            alpha3Code: "TCY"
        )
        
        viewModel = CountryDetailViewModel(
            country: noCapitalCountry,
            storageService: mockStorageService
        )
        
        // Assert
        XCTAssertEqual(viewModel.capital, "No capital information")
    }
}
