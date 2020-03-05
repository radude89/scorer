//
//  PlayerController.swift
//  
//
//  Created by Radu Dan on 03/03/2020.
//

import Vapor
import ScorerFoundation

struct PlayerController: RouteCollection {
    func boot(router: Router) throws {
        let playersRoute = router.grouped("api", "players")
        playersRoute.post(Player.self, use: createHandler)
        playersRoute.get(use: getAllHandler)
        playersRoute.get(Player.parameter, use: getHandler)
        playersRoute.put(Player.parameter, use: updateHandler)
        playersRoute.delete(Player.parameter, use: deleteHandler)
        playersRoute.get(Player.parameter, "gathers", use: getGathersHandler)
    }
    
    func createHandler(_ req: Request, player: Player) throws -> Future<Player> {
        return player.save(on: req)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Player]> {
        return Player.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Player> {
        return try req.parameters.next(Player.self)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Player> {
        return try flatMap(to: Player.self, req.parameters.next(Player.self), req.content.decode(Player.self)) { player, updatedPlayer in
            player.name = updatedPlayer.name
            
            if let age = updatedPlayer.age {
                player.age = age
            }
            
            if let favouriteTeam = updatedPlayer.favouriteTeam {
                player.favouriteTeam = favouriteTeam
            }
            
            if let preferredPosition = updatedPlayer.preferredPosition {
                player.preferredPosition = preferredPosition
            }
            
            if let skill = updatedPlayer.skill {
                player.skill = skill
            }
            
            player.lastUpdated = Date()
            
            return player.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Player.self).flatMap(to: HTTPStatus.self) { player in
            return player.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
    
    func getGathersHandler(_ req: Request) throws -> Future<[Gather]> {
        return try req.parameters.next(Player.self).flatMap(to: [Gather].self) { player in
            return try player.gathers.query(on: req).all()
        }
    }
    
}
