//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import Foundation

public extension Date {
    func adding(days: Int) -> Date {
        return Date().addingTimeInterval(TimeInterval.day * Double(days))
    }

    func removing(days: Int) -> Date {
        return adding(days: -days)
    }
}
