//
//  CoordinatorView.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/26/25.
//

import SwiftUI

struct CoordinatorView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let navigationController = UINavigationController()
        
        // Configure appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        
        // Start the coordinator
        let coordinator = AppCoordinator(navigationController: navigationController)
        context.coordinator.coordinator = coordinator
        coordinator.start()
        
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Nothing to update
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var coordinator: AppCoordinator?
    }
}
