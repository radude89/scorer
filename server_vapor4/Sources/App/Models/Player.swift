//
//  Player.swift
//  
//
//  Created by Radu Dan on 03/04/2020.
//

import Vapor
import FluentSQLiteDriver

final class Player: Model {
    static let schema = "players"
    
    @ID(custom: .id)
    var id: Int?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "age")
    var age: Int?
    
    @Field(key: "player_skill")
    var skill: PlayerSkill?
    
    @Field(key: "player_position")
    var preferredPosition: PlayerPosition?
    
    @Field(key: "favourite_team")
    var favouriteTeam: String?
    
    @Field(key: "last_updated")
    var lastUpdated: Date?
    
    @Siblings(through: PlayerGather.self, from: \.$player, to: \.$gather)
    public var gathers: [Gather]
    
    convenience init() {
        self.init(name: "")
    }
    
    init(id: Int? = nil,
         name: String,
         age: Int? = nil,
         skill: PlayerSkill? = nil,
         preferredPosition: PlayerPosition? = nil,
         favouriteTeam: String? = nil,
         lastUpdated: Date? = nil) {
        self.id = id
        self.name = name
        self.age = age
        self.skill = skill
        self.preferredPosition = preferredPosition
        self.favouriteTeam = favouriteTeam
        self.lastUpdated = lastUpdated
    }
}

extension Player: Content {}
extension Player: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Player.schema)
            .field("id", .int, .identifier(auto: true))
            .field("name", .string, .required)
            .field("age", .int)
            .field("player_skill", .string)
            .field("player_position", .string)
            .field("favourite_team", .string)
            .field("last_updated", .date)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Player.schema).delete()
    }
}

enum PlayerSkill: String, Codable, CaseIterable {
    case beginner, amateur, professional
}

enum PlayerPosition: String, Codable, CaseIterable {
    case goalkeeper, defender, midfielder, winger, striker
    
    var acronym: String {
        switch self {
        case .goalkeeper: return "GK"
        case .winger: return "W"
        case .striker: return "ST"
        default: return rawValue.prefix(3).uppercased()
        }
    }
}
