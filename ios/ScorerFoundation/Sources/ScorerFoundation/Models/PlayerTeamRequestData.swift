//
//  PlayerTeamRequestData.swift
//  Scorer
//
//  Created by Radu Dan on 04/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

public struct PlayerTeamRequestData: Codable {
    public let team: TeamSection
    public let playerID: Int
}
