//
//  PlayerController.swift
//  
//
//  Created by Radu Dan on 03/04/2020.
//

import Vapor
import Fluent

struct PlayerController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let playerRoute = routes.grouped("api", "players")
        playerRoute.post(use: create)
        playerRoute.get(use: getAll)
        playerRoute.get(":id", use: get)
        playerRoute.put(":id", use: update)
        playerRoute.delete(":id", use: delete)
        playerRoute.get(":id", "gathers", use: getGathers)
    }
    
    func create(req: Request) throws -> EventLoopFuture<Player> {
        let player = try req.content.decode(Player.self)
        return player.save(on: req.db).map { player }
    }
    
    func getAll(_ req: Request) throws -> EventLoopFuture<[Player]> {
        return Player.query(on: req.db).all()
    }
    
    func get(_ req: Request) throws -> EventLoopFuture<Player> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            throw Abort(.badRequest)
        }
        
        return Player.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func update(req: Request) throws -> EventLoopFuture<Player> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            throw Abort(.badRequest)
        }
        
        let updatedPlayer = try req.content.decode(Player.self)
        return Player.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { player in
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
                
                return player.save(on: req.db).map { player }
        }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: Int.self) else {
            throw Abort(.badRequest)
        }
        return Player.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .map { .ok }
    }
    
    func getGathers(req: Request) throws -> EventLoopFuture<[Gather]> {
        let player = Player.find(req.parameters.get("id", as: Int.self), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return player.flatMap { $0.$gathers.query(on: req.db).all() }
    }
}
