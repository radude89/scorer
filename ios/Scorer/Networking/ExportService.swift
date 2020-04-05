//
//  ExportService.swift
//  Scorer
//
//  Created by Radu Dan on 05/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation
import ScorerFoundation

struct ExportService: NetworkService {
    
    var session: NetworkSession
    var urlRequest: URLRequestFactory
    
    init(session: NetworkSession = URLSession.shared,
         urlRequest: URLRequestFactory = StandardURLRequestFactory(endpoint: StandardEndpoint("/api/gathers/export"))) {
        self.session = session
        self.urlRequest = urlRequest
    }
    
    func exportGathers(completion: @escaping (Bool) -> Void) {
        var request = urlRequest.makeURLRequest()
        request.httpMethod = "POST"
        
        session.loadData(from: request) { (data, response, error) in
            if let error = error {
                print(error)
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Unexpected response")
                completion(false)
                return
            }
            
            completion(true)
        }
    }
}
