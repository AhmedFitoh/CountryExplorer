//
//  StorageError.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/25/25.
//

import Foundation

enum StorageError: Error {
    case saveFailed
    case loadFailed
    case countryLimitReached
    case countryAlreadyExists
    
    var localizedDescription: String {
        switch self {
        case .saveFailed:
            return "Failed to save data"
        case .loadFailed:
            return "Failed to load data"
        case .countryLimitReached:
            return "You can only save up to 5 countries"
        case .countryAlreadyExists:
            return "This country is already saved"
        }
    }
}
