//
//  PlayerGatherPivot.swift
//  
//
//  Created by Radu Dan on 04/03/2020.
//

import FluentSQLite
import Vapor
import ScorerFoundation

final class PlayerGatherPivot: SQLiteUUIDPivot {
    var id: UUID?
    var playerId: Player.ID
    var gatherId: Gather.ID
    var team: String
    
    typealias Left = Player
    typealias Right = Gather
    
    static var leftIDKey: LeftIDKey = \PlayerGatherPivot.playerId
    static var rightIDKey: RightIDKey = \PlayerGatherPivot.gatherId
    
    init(playerId: Player.ID, gatherId: Gather.ID, team: String) {
        self.playerId = playerId
        self.gatherId = gatherId
        self.team = team
    }
    
}

extension PlayerGatherPivot: Migration {
    public static func prepare(on connection: SQLiteConnection) -> EventLoopFuture<Void> {
        return Database.create(PlayerGatherPivot.self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.playerId, to: \Player.id)
            builder.reference(from: \.gatherId, to: \Gather.id)
        }
    }
}
