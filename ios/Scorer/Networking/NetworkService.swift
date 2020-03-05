//
//  NetworkService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 02/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - NetworkService
protocol NetworkService {
    var session: NetworkSession { get set }
    var urlRequest: URLRequestFactory { get set }
    
    func create<Resource: Encodable>(_ resource: Resource, completion: @escaping (Result<ResourceID, Error>) -> Void)
    func get<Resource: Decodable>(completion: @escaping (Result<[Resource], Error>) -> Void)
    mutating func delete(withID resourceID: ResourceID, completion: @escaping (Result<Bool, Error>) -> Void)
    mutating func update<Resource: Encodable>(_ resource: Resource, resourceID: ResourceID, completion: @escaping (Result<Bool, Error>) -> Void)
}

// MARK: - ID model
enum ResourceID {
    case integer(Int)
    case uuid(UUID)
}

// MARK: - Basic implementation
struct StandardNetworkService: NetworkService {
    var session: NetworkSession
    var urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    init(resourcePath: String) {
        let endpoint = StandardEndpoint(path: resourcePath)
        self.init(urlRequest: StandardURLRequestFactory(endpoint: endpoint))
    }
}
