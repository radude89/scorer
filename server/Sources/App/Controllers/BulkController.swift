//
//  BulkController.swift
//  
//
//  Created by Radu Dan on 05/03/2020.
//

import Vapor
import ScorerFoundation

struct BulkController: RouteCollection {
    func boot(router: Router) throws {
        let gathersRoute = router.grouped("api", "gathers")
        gathersRoute.post([Gather].self, at: "bulk", use: createGatherBulkHandler)
        
        let playersRoute = router.grouped("api", "players")
        playersRoute.post([Player].self, at: "bulk", use: createPlayerBulkHandler)
    }
    
    func createGatherBulkHandler(_ req: Request, gathers: [Gather]) throws -> Future<Response> {
        return gathers.map { $0.save(on: req) }.flatten(on: req).map { tasks in
            var httpResponse = HTTPResponse()
            httpResponse.status = .created
            let response = Response(http: httpResponse, using: req)
            return response
        }
    }
    
    func createPlayerBulkHandler(_ req: Request, players: [Player]) throws -> Future<Response> {
        return players.map { $0.save(on: req) }.flatten(on: req).map { tasks in
            var httpResponse = HTTPResponse()
            httpResponse.status = .created
            let response = Response(http: httpResponse, using: req)
            return response
        }
    }
}
