//
//  Gather.swift
//  
//
//  Created by Radu Dan on 03/04/2020.
//

import Vapor
import FluentSQLiteDriver

final class Gather: Model {
    static let schema = "gathers"
    
    @ID(key: "id")
    var id: UUID?
    
    @Field(key: "score")
    var score: String?
    
    @Field(key: "winner_team")
    var winnerTeam: String?
    
    @Siblings(through: PlayerGather.self, from: \.$gather, to: \.$player)
    public var players: [Player]
    
    init() {}
    
    init(id: UUID? = nil, score: String? = nil, winnerTeam: String? = nil) {
        self.id = id
        self.score = score
        self.winnerTeam = winnerTeam
    }
    
}

extension Gather: Content {}
extension Gather: Migration {
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Gather.schema)
            .field("id", .uuid, .identifier(auto: true))
            .field("score", .string)
            .field("winner_team", .string)
            .create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Gather.schema).delete()
    }
}
