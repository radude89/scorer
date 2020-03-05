//
//  PlayerViewState.swift
//  Scorer
//
//  Created by Radu Dan on 03/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerListViewState
enum PlayerListViewState {
    case list
    case selection
    
    mutating func toggle() {
        self = self == .list ? .selection : .list
    }
}
