//
//  ScoreFoundationAdapter.swift
//  
//
//  Created by Radu Dan on 05/03/2020.
//

import ScorerFoundation
import Vapor
import FluentSQLite

extension Gather: SQLiteUUIDModel {}
extension Gather: Content {}
extension Gather: Parameter {}
extension Gather: Migration {}

extension Player: SQLiteModel {}
extension Player: Content {}
extension Player: Parameter {}
extension Player: Migration {}

extension PlayerTeam: Content {}

extension PlayerSkill: ReflectionDecodable {}
extension PlayerPosition: ReflectionDecodable {}
extension TeamSection: ReflectionDecodable {}

extension Gather {
    var players: Siblings<Gather, Player, PlayerGatherPivot> {
        return siblings()
    }
}

extension Player {
    var gathers: Siblings<Player, Gather, PlayerGatherPivot> {
        return siblings()
    }
}
