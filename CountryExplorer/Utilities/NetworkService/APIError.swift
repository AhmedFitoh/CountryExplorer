//
//  APIError.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/25/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case networkError(Error)
    case serverError(Int)
    case noData
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .decodingError:
            return "Failed to decode data"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error: \(statusCode)"
        case .noData:
            return "No data received"
        }
    }
}
