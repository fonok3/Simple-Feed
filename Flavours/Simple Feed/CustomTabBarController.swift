//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)
        let feedNavigationController = SFNavigationController(rootViewController: NewsFeedTVCUnread())
        feedNavigationController.tabBarItem.image = UIImage(named: "Feed")

        let taggedNavigationController = SFNavigationController(rootViewController: NewsFeedTVCTag())
        taggedNavigationController.tabBarItem.image = UIImage(named: "labelSelected")

        var feedsController: UIViewController?
        switch UserDefaults.standard.integer(forKey: "feedsView") {
        case 2:
            feedsController = FeedsTVC(style: .plain)
            feedsController!.title = NSLocalizedString("FEEDS", comment: "Feeds")
        default:
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            feedsController = FeedsCVC(collectionViewLayout: layout)
            feedsController!.title = NSLocalizedString("FEEDS", comment: "Feeds")
        }
        let sectionsNavigationController = SFNavigationController(rootViewController: feedsController!)
        sectionsNavigationController.tabBarItem.image = UIImage(named: "sectionsSelected")

        let readNavigationController = SFNavigationController(rootViewController: NewsFeedTVCRead())
        readNavigationController.tabBarItem.image = UIImage(named: "readSelected")

        let settings = SettingsTVC()
        let settingsNavigationController = SFNavigationController(rootViewController: settings)
        settingsNavigationController.title = NSLocalizedString("SETTINGS", comment: "Settings")
        settingsNavigationController.tabBarItem.image = UIImage(named: "settingsSelected")

        viewControllers = [feedNavigationController, taggedNavigationController,
                           sectionsNavigationController, readNavigationController, settingsNavigationController]

        tabBar.isTranslucent = false

        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: 1000, height: 0.5)
        topBorder.backgroundColor = UIColor(red: 229, green: 231, blue: 235).cgColor

        tabBar.layer.addSublayer(topBorder)
        tabBar.clipsToBounds = true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
