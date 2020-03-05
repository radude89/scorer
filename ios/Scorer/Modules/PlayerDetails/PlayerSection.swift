//
//  PlayerSection.swift
//  Scorer
//
//  Created by Radu Dan on 03/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation
import ScorerFoundation

struct PlayerSection {
    let title: String
    let rows: [PlayerRow]
}

struct PlayerRow {
    let title: String
    let value: String
    let editableField: PlayerEditableFieldOption
}

enum PlayerSectionFactory {
    static func makeSections(fromPlayer player: Player) -> [PlayerSection] {
        return [
            PlayerSection(
                title: "Personal",
                rows: [
                    PlayerRow(title: "Name",
                              value: player.name,
                              editableField: .name),
                    PlayerRow(title: "Age",
                              value: player.age != nil ? "\(player.age!)" : "",
                              editableField: .age)
                ]
            ),
            PlayerSection(
                title: "Play",
                rows: [
                    PlayerRow(title: "Preferred position",
                              value: player.preferredPosition?.rawValue.capitalized ?? "",
                              editableField: .position),
                    PlayerRow(title: "Skill",
                              value: player.skill?.rawValue.capitalized ?? "",
                              editableField: .skill)
                ]
            ),
            PlayerSection(
                title: "Likes",
                rows: [
                    PlayerRow(title: "Favourite team",
                              value: player.favouriteTeam ?? "",
                              editableField: .favouriteTeam)
                ]
            )
        ]
    }
}
