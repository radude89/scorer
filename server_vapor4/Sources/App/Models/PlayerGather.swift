//
//  PlayerGather.swift
//  
//
//  Created by Radu Dan on 03/04/2020.
//

import Vapor
import FluentSQLiteDriver

final class PlayerGather: Model {
    static let schema = "player_gather"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "player_id")
    var player: Player
    
    @Parent(key: "gather_id")
    var gather: Gather
    
    @Field(key: "team")
    var team: String?
    
    init() {}

    init(playerID: Int, gatherID: UUID, team: String? = nil) {
        self.$player.id = playerID
        self.$gather.id = gatherID
        self.team = team
    }
    
}

extension PlayerGather: Content {}
extension PlayerGather: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PlayerGather.schema)
            .field("id", .uuid, .identifier(auto: true))
            .field("player_id", .int, .required)
            .field("gather_id", .uuid, .required)
            .field("team", .string)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(PlayerGather.schema).delete()
    }
}

