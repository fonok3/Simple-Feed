//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import UIKit

class SFNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let nav = navigationBar

        let img = UIImage()
        nav.shadowImage = img
        nav.backgroundColor = nav.barTintColor

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -12)

            appearance.largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]

            appearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]

            appearance.backgroundColor = FHColor.simpleFeedColor

            nav.standardAppearance = appearance
            nav.scrollEdgeAppearance = appearance
            nav.compactAppearance = appearance
        } else {
            UINavigationBar.appearance().barTintColor = FHColor.simpleFeedColor

            UINavigationBar.appearance().titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]
            UINavigationBar.appearance().largeTitleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]
        }

        UINavigationBar.appearance().tintColor = UIColor.white
        nav.prefersLargeTitles = true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}
