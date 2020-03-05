//
//  Player.swift
//  Scorer
//
//  Created by Radu Dan on 02/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

public final class Player: Codable {
    public var id: Int?
    public var name: String
    public var age: Int?
    public var skill: PlayerSkill?
    public var preferredPosition: PlayerPosition?
    public var favouriteTeam: String?
    public var lastUpdated: Date?
}

public enum PlayerSkill: String, Codable, CaseIterable {
    case beginner, amateur, professional
}

public enum PlayerPosition: String, Codable, CaseIterable {
    case goalkeeper, defender, midfielder, winger, striker
    
    public var acronym: String {
        switch self {
        case .goalkeeper: return "GK"
        case .winger: return "W"
        case .striker: return "ST"
        default: return rawValue.prefix(3).uppercased()
        }
    }
}

extension Player: Equatable {
    public static func ==(lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
}
