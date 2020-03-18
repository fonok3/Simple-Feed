//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
}
