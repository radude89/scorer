//
//  TeamSection.swift
//  Scorer
//
//  Created by Radu Dan on 03/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

public enum TeamSection: Int, Codable, CaseIterable {
    case bench = 0, teamA, teamB
}

extension TeamSection {
    public var teamDescription: String {
        switch self {
        case .bench: return "Bench"
        case .teamA: return "Team A"
        case .teamB: return "Team B"
        }
    }
}
