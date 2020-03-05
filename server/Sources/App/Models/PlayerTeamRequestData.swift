//
//  PlayerTeamRequestData.swift
//  
//
//  Created by Radu Dan on 04/03/2020.
//

import Vapor
import ScorerFoundation

public struct PlayerTeamRequestData: Codable {
    public let team: TeamSection
    public let playerID: Int
}

extension PlayerTeamRequestData: Content {}
