//
//  LocationServiceProtocol.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/25/25.
//

import Foundation
import CoreLocation

protocol LocationServiceProtocol {
    func getCurrentLocation() async throws -> CLLocation
    func getCountryCode(from location: CLLocation) async throws -> String
}

class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    private var geocodeContinuation: CheckedContinuation<String, Error>?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func getCurrentLocation() async throws -> CLLocation {
        let authStatus = locationManager.authorizationStatus
        
        switch authStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            throw LocationError.permissionDenied
        default:
            break
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()
        }
    }
    
    func getCountryCode(from location: CLLocation) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            self.geocodeContinuation = continuation
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if error != nil {
                    continuation.resume(throwing: LocationError.unknownError)
                    return
                }
                
                guard let countryCode = placemarks?.first?.isoCountryCode else {
                    continuation.resume(throwing: LocationError.locationNotFound)
                    return
                }
                
                continuation.resume(returning: countryCode)
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            locationContinuation?.resume(throwing: LocationError.locationNotFound)
            return
        }
        
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: LocationError.unknownError)
        locationContinuation = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        if status == .denied || status == .restricted {
            locationContinuation?.resume(throwing: LocationError.permissionDenied)
            locationContinuation = nil
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            // Authorization granted, we'll wait for the location update
        }
    }
}
