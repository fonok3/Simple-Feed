//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import UIKit

class CardView: UIView {
    var shadow = true

    override func layoutSubviews() {
        super.layoutSubviews()

        if shadow {
            layer.masksToBounds = false
            layer.cornerRadius = 7.5
        }
    }
}
