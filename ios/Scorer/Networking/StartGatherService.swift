//
//  StartGatherService.swift
//  Scorer
//
//  Created by Radu Dan on 05/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation
import ScorerFoundation

struct StartGatherService: NetworkService {
    
    var session: NetworkSession
    var urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = StandardURLRequestFactory(endpoint: StandardEndpoint("/api/gathers/start"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func startGather(with playerTeams: [PlayerTeam], completion: @escaping (UUID?) -> Void) {
        var request = urlRequest.makeURLRequest()
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(playerTeams)
        
        session.loadData(from: request) { (data, response, error) in
            if let error = error {
                print(error)
                completion(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                print("Unexpected response")
                completion(nil)
                return
            }
            
            if let uuidModel = try? JSONDecoder().decode(UUIDModel.self, from: data) {
                completion(uuidModel.id)
            } else {
                completion(nil)
            }
        }
    }
}
