//
//  GatherController.swift
//  
//
//  Created by Radu Dan on 04/03/2020.
//

import Vapor
import ScorerFoundation

struct GatherController: RouteCollection {
    func boot(router: Router) throws {
        let gathersRoute = router.grouped("api", "gathers")
        gathersRoute.post(Gather.self, use: createHandler)
        gathersRoute.get(use: getAllHandler)
        gathersRoute.get(Gather.parameter, use: getHandler)
        gathersRoute.put(Gather.parameter, use: updateHandler)
        gathersRoute.delete(Gather.parameter, use: deleteHandler)
        gathersRoute.post(Gather.parameter, "players", Player.parameter, use: addPlayerHandler)
        gathersRoute.get(Gather.parameter, "players", use: getPlayersHandler)
        gathersRoute.post([PlayerTeamRequestData].self, at: "start", use: startGather)
    }
    
    func createHandler(_ req: Request, gather: Gather) throws -> Future<Gather> {
        return gather.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Gather]> {
        return Gather.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Gather> {
        return try req.parameters.next(Gather.self)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Gather> {
        return try flatMap(to: Gather.self, req.parameters.next(Gather.self), req.content.decode(Gather.self)) { gather, updatedGather in
            if let score = updatedGather.score {
                gather.score = score
            }
            
            if let winnerTeam = updatedGather.winnerTeam {
                gather.winnerTeam = winnerTeam
            }
                        
            return gather.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Gather.self).flatMap(to: HTTPStatus.self) { gather in
            return gather.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
    
    func addPlayerHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self,
                           req.parameters.next(Gather.self),
                           req.parameters.next(Player.self),
                           req.content.decode(PlayerGatherCreateData.self)) { gather, player, playerGather in
                            
                            let pivot = try PlayerGatherPivot(playerId: player.requireID(), gatherId: gather.requireID(), team: playerGather.team)
                            return pivot.save(on: req).transform(to: .ok)
        }
    }
    
    func getPlayersHandler(_ req: Request) throws -> Future<[Player]> {
        return try req.parameters.next(Gather.self).flatMap(to: [Player].self) { gather in
            return try gather.players.query(on: req).all()
        }
    }
    
    func startGather(_ req: Request, playerTeams: [PlayerTeamRequestData]) throws -> Future<Gather> {
        return Gather().save(on: req).map { gather in
            
            try playerTeams.forEach {
                let pivot = try PlayerGatherPivot(playerId: $0.playerID, gatherId: gather.requireID(), team: $0.team.teamDescription)
                _ = pivot.save(on: req)
            }
            
            return gather
        }
    }
    
}

struct PlayerGatherCreateData: Content {
    let team: String
}
