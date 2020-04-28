//
//  GatherController.swift
//  
//
//  Created by Radu Dan on 04/03/2020.
//

import Vapor
import Fluent

struct GatherController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let gathersRoute = routes.grouped("api", "gathers")
        gathersRoute.post(use: create)
        gathersRoute.get(use: getAll)
        gathersRoute.get(":id", use: get)
        gathersRoute.put(":id", use: update)
        gathersRoute.delete(":id", use: delete)
        gathersRoute.get(":id", "players", use: getPlayers)
        gathersRoute.post(":gatherID", "players", ":playerID", use: addPlayer)
    }
        
    func create(req: Request) throws -> EventLoopFuture<Gather> {
        let gather = try req.content.decode(Gather.self)
        return gather.create(on: req.db).map { gather }
    }
    
    func getAll(req: Request) throws -> EventLoopFuture<[Gather]> {
        return Gather.query(on: req.db).all()
    }
    
    func get(req: Request) throws -> EventLoopFuture<Gather> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return Gather.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func update(req: Request) throws -> EventLoopFuture<Gather> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        let updatedGather = try req.content.decode(Gather.self)
        
        return Gather.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { gather in
                if let score = updatedGather.score {
                    gather.score = score
                }
                
                if let winnerTeam = updatedGather.winnerTeam {
                    gather.winnerTeam = winnerTeam
                }
                
                return gather.save(on: req.db).map { gather }
        }
    }
    
    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        return Gather.find(id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .map { .ok }
    }
    
    func getPlayers(req: Request) throws -> EventLoopFuture<[Player]> {
        let gather = Gather.find(req.parameters.get("id", as: UUID.self), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return gather.flatMap { $0.$players.query(on: req.db).all() }
    }
    
    func addPlayer(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let gather = Gather.find(req.parameters.get("gatherID", as: UUID.self), on: req.db)
            .unwrap(or: Abort(.notFound))
        let player = Player.find(req.parameters.get("playerID", as: Int.self), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return gather.and(player).flatMap { (gather, player) in
            gather.$players.attach(player, on: req.db)
        }.transform(to: .ok)
    }
}
