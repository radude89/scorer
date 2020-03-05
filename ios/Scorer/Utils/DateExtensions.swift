//
//  DateExtensions.swift
//  Scorer
//
//  Created by Radu Dan on 05/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

extension Date {
    var formattedString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: self)
    }
}
