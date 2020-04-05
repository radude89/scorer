//
//  GatherBFFController.swift
//  
//
//  Created by Radu Dan on 05/04/2020.
//

import Vapor
import ScorerFoundation

struct GatherBFFController: RouteCollection {
    
    func boot(router: Router) throws {
        let gathersRoute = router.grouped("api", "gathers")
        gathersRoute.post([PlayerTeam].self, at: "start", use: startGather)
    }
    
    func startGather(_ req: Request, playerTeams: [PlayerTeam]) throws -> Future<Gather> {
        return Gather().save(on: req).map { gather in
            
            try playerTeams.forEach {
                let pivot = try PlayerGatherPivot(playerId: $0.player.id!, gatherId: gather.requireID(), team: $0.team.teamDescription)
                _ = pivot.save(on: req)
            }
            
            return gather
        }
    }
}
