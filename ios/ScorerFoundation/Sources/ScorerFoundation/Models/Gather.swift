//
//  Gather.swift
//  Scorer
//
//  Created by Radu Dan on 03/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

public final class Gather: Codable {
    public var id: UUID?
    public var score: String?
    public var winnerTeam: String?
    
    public init(id: UUID? = nil, score: String? = nil, winnerTeam: String? = nil) {
        self.id = id
        self.score = score
        self.winnerTeam = winnerTeam
    }
    
}
