//
//  PlayerTeam.swift
//  Scorer
//
//  Created by Radu Dan on 04/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

public struct PlayerTeam: Codable {
    public let team: TeamSection
    public let player: Player
    
    public init(team: TeamSection, player: Player) {
        self.team = team
        self.player = player
    }
}
