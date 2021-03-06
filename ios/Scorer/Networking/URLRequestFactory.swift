//
//  URLRequestFactory.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 15/04/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - ServiceRequest
protocol URLRequestFactory {
    func makeURLRequest() -> URLRequest
    var defaultHeaders: [String: String] { get }
    var endpoint: Endpoint { get set }
}

extension URLRequestFactory {
    var defaultHeaders: [String: String] {
        return ["Content-Type": "application/json", "Accept": "application/json"]
    }
}

// MARK: - Default URL request factory
struct StandardURLRequestFactory: URLRequestFactory {
    var endpoint: Endpoint
    
    func makeURLRequest() -> URLRequest {
        guard let url = endpoint.url else {
            fatalError("Unable to make url request")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = defaultHeaders
        
        return urlRequest
    }
}
