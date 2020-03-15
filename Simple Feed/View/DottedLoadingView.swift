//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import UIKit

class DottedLoadingView: UIView {
    private let dotOne: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(displayP3Red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 7.5
        view.isHidden = true
        return view
    }()

    private let dotTwo: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(displayP3Red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 7.5
        view.isHidden = true
        return view
    }()

    private let dotThree: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(displayP3Red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 7.5
        view.isHidden = true
        return view
    }()

    var timer: Timer?
    var state = 0

    var loading = false

    func startLoading() {
        guard !loading else { return }

        loading = true

        dotOne.isHidden = false
        dotTwo.isHidden = false
        dotThree.isHidden = false

        timer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true) { _ in
            DispatchQueue.main.async {
                switch self.state {
                case 0:
                    self.dotOne.backgroundColor = UIColor(displayP3Red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
                    self.dotTwo.backgroundColor = UIColor(displayP3Red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
                    self.dotThree.backgroundColor = UIColor(displayP3Red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
                case 1:
                    self.dotOne.backgroundColor = UIColor(displayP3Red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
                    self.dotTwo.backgroundColor = UIColor(displayP3Red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
                    self.dotThree.backgroundColor = UIColor(displayP3Red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
                default:
                    self.dotOne.backgroundColor = UIColor(displayP3Red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
                    self.dotTwo.backgroundColor = UIColor(displayP3Red: 0.85, green: 0.85, blue: 0.85, alpha: 1)
                    self.dotThree.backgroundColor = UIColor(displayP3Red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
                }
                self.state = (self.state + 1) % 3
            }
        }
        timer?.fire()
    }

    func stopLoading() {
        loading = false

        dotOne.isHidden = true
        dotTwo.isHidden = true
        dotThree.isHidden = true
        timer?.invalidate()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundColor = .clear

        addSubview(dotOne)
        addSubview(dotTwo)
        addSubview(dotThree)

        addConstraintsWithFormat("H:|[v0(15)]-10-[v1(15)]-10-[v2(15)]|", views: dotOne, dotTwo, dotThree)
        addConstraintsWithFormat("V:|[v0(15)]", views: dotOne)
        addConstraintsWithFormat("V:|[v0(15)]", views: dotTwo)
        addConstraintsWithFormat("V:|[v0(15)]", views: dotThree)
    }
}
