//
//  CountryExplorerApp.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/25/25.
//

import SwiftUI

@main
struct CountryExplorerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
