//
//  CreateNetworkService.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 02/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation

extension NetworkService {
    func create<Resource: Encodable>(_ resource: Resource, completion: @escaping (Result<ResourceID, Error>) -> Void) {
        var request = urlRequest.makeURLRequest()
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(resource)
        
        session.loadData(from: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(ServiceError.unexpectedResponse))
                return
            }
            
            guard let data = data, data.isEmpty == false else {
                completion(.failure(ServiceError.unexpectedResponse))
                return
            }
            
            if let uuidModel = try? JSONDecoder().decode(UUIDModel.self, from: data) {
                completion(.success(ResourceID.uuid(uuidModel.id)))
            } else if let intIDModel = try? JSONDecoder().decode(IntIDModel.self, from: data) {
                completion(.success(ResourceID.integer(intIDModel.id)))
            } else {
                completion(.failure(ServiceError.unexpectedResourceIDType))
            }
        }
    }
}

private struct UUIDModel: Decodable {
    let id: UUID
}

private struct IntIDModel: Decodable {
    let id: Int
}
