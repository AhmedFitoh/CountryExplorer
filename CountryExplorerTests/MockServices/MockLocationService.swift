//
//  MockLocationService.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/26/25.
//

import Foundation
import CoreLocation
@testable import CountryExplorer

class MockLocationService: LocationServiceProtocol {
    var shouldFailLocation = false
    var shouldFailGeocode = false
    var mockedLocation = CLLocation(latitude: 30.0444, longitude: 31.2357) // Cairo
    var mockedCountryCode = "EG"
    
    func getCurrentLocation() async throws -> CLLocation {
        if shouldFailLocation {
            throw LocationError.permissionDenied
        }
        return mockedLocation
    }
    
    func getCountryCode(from location: CLLocation) async throws -> String {
        if shouldFailGeocode {
            throw LocationError.locationNotFound
        }
        return mockedCountryCode
    }
}
