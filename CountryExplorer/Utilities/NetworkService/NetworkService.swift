//
//  NetworkRequest.swift
//  CountryExplorer
//
//  Created by AhmedFitoh on 3/25/25.
//

import Foundation

// MARK: - NetworkRequest Protocol
protocol NetworkRequest {
    associatedtype Response
    
    var url: URL { get throws }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    
    func decode(_ data: Data) throws -> Response
}

// Default implementations
extension NetworkRequest {
    var method: HTTPMethod { .get }
    var headers: [String: String] { [:] }
}

// MARK: - HTTP Method Enum
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Network Service
protocol NetworkServiceProtocol {
    func execute<R: NetworkRequest>(_ request: R) async throws -> R.Response
}

class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func execute<R: NetworkRequest>(_ request: R) async throws -> R.Response {
        // Create URL from request
        let url: URL
        do {
            url = try request.url
        } catch {
            throw APIError.invalidURL
        }
        
        // Create URL request
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        // Add headers
        request.headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        
        // Execute request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw APIError.networkError(error)
        }
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        // Decode response
        do {
            return try request.decode(data)
        } catch {
            throw APIError.decodingError
        }
    }
}
