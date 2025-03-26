//
//  AppCoordinator.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/25/25.
//

import Foundation
import UIKit
import SwiftUI

class AppCoordinator: NSObject, Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let apiService: APIServiceProtocol
    private let locationService: LocationServiceProtocol
    private let storageService: StorageServiceProtocol
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.navigationBar.prefersLargeTitles = true
        
        // Initialize services
        self.apiService = APIService(networkService: NetworkService())
        self.locationService = LocationService()
        self.storageService = StorageService()
        
        super.init()
    }
    
    func start() {
        initializeCache()
        showCountryList()
    }
    
    private func initializeCache() {
        Task {
            await (apiService as? APIService)?.cacheAllCountries()
        }
    }

    private func showCountryList() {
        let viewModel = CountryListViewModel(
            apiService: apiService,
            locationService: locationService,
            storageService: storageService,
            coordinatorDelegate: self
        )
        
        let countryListView = CountryListView(viewModel: viewModel,
                                              coordinator: self)
        let hostingController = UIHostingController(rootView: countryListView)
        navigationController.pushViewController(hostingController, animated: false)
    }
    
}

// MARK: - CountryListCoordinatorDelegate
extension AppCoordinator: CountryListCoordinatorDelegate {
    func showCountryDetail(country: Country) {
        let detailCoordinator = CountryDetailCoordinator(
            navigationController: navigationController,
            country: country,
            storageService: storageService
        )
        childCoordinators.append(detailCoordinator)
        detailCoordinator.parentCoordinator = self
        detailCoordinator.start()
    }
    
}
