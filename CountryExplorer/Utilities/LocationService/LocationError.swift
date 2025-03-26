//
//  LocationError.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/25/25.
//

import Foundation

enum LocationError: Error {
    case permissionDenied
    case locationNotFound
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .permissionDenied:
            return "Location permission denied"
        case .locationNotFound:
            return "Location not found"
        case .unknownError:
            return "Unknown location error"
        }
    }
}
