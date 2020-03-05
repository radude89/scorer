//
//  PlayerEditModel.swift
//  Scorer
//
//  Created by Radu Dan on 03/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import ScorerFoundation

struct PlayerEditModel {
    var player: Player
    let playerRow: PlayerRow
}

struct PlayerItemsEditModel {
    let items: [String]
    var selectedItemIndex: Int
}

enum PlayerEditableFieldOption {
    case name, age, skill, position, favouriteTeam
}

extension Player {
    func update(usingField field: PlayerEditableFieldOption, value: String) {
        switch field {
        case .name:
            name = value
        case .age:
            age = Int(value)
        case .position:
            if let position = PlayerPosition(rawValue: value) {
                preferredPosition = position
            }
        case .skill:
            if let skill = PlayerSkill(rawValue: value) {
                self.skill = skill
            }
        case .favouriteTeam:
            favouriteTeam = value
        }
    }
}
