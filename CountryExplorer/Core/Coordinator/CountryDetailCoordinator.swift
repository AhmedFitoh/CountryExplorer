//
//  CountryDetailCoordinator.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/26/25.
//
import Foundation
import UIKit
import SwiftUI

/// Navigation actions that can be initiated from the CountryDetailViewModel
protocol CountryDetailCoordinatorDelegate: AnyObject {
    func dismissCountryDetail()
}

class CountryDetailCoordinator: NSObject, Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: AppCoordinator?
    
    private let country: Country
    private let storageService: StorageServiceProtocol
    
    init(navigationController: UINavigationController,
         country: Country,
         storageService: StorageServiceProtocol) {
        self.navigationController = navigationController
        self.country = country
        self.storageService = storageService
        
        super.init()
    }
    
    func start() {
        let viewModel = CountryDetailViewModel(
            country: country,
            storageService: storageService)
        
        let detailView = CountryDetailView(viewModel: viewModel, onDismiss: dismissCountryDetail)
        let hostingController = UIHostingController(rootView: detailView)
        navigationController.pushViewController(hostingController, animated: true)
    }
}

// MARK: - CountryDetailCoordinatorDelegate
extension CountryDetailCoordinator: CountryDetailCoordinatorDelegate {
    func dismissCountryDetail() {
        navigationController.popViewController(animated: true)
        parentCoordinator?.childDidFinish(self)
    }
}
