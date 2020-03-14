//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import AVFoundation
import CoreData
import SimpleFeedCore
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?

    static func shareAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    var mainVC: CustomTabBarController?
    var refreshStatus: RefreshStatus = .nothing

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setAppDefaults()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        mainVC = CustomTabBarController()
        window?.rootViewController = mainVC

        window?.tintColor = FHColor.simpleFeedRed

        return true
    }

    func setAppDefaults() {
        let appDefaults = [userDefaults.DELETE_ARTICLE_AFTER_DAYS: 2,
                           userDefaults.ACTIVATE_READER_AUTO: true,
                           userDefaults.FIRST_START: true,
                           userDefaults.ICLOUD_ENABLED: false,
                           userDefaults.IMAGE_LOADING: userDefaults.ImageLoading.always,
                           userDefaults.KEEP_LAST_READ: true,
                           userDefaults.CLEARED_DATABASE: false,
                           userDefaults.TITLE_LINES: 2,
                           userDefaults.PREVIEW_LINES: 3,
                           userDefaults.GROUP_NEWS_FEED_BY_FEED: false] as [String: Any]

        UserDefaults.standard.register(defaults: appDefaults)
        UserDefaults.standard.synchronize()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        refreshShorcutItems(application)
        try? CoreDataService.shared.viewContext.saveAndWaitWhenChanged()
    }

    func applicationWillTerminate(_: UIApplication) {
        try? CoreDataService.shared.viewContext.saveAndWaitWhenChanged()
    }

    // MARK: - ShortcutItems

    func refreshShorcutItems(_ application: UIApplication) {
        application.shortcutItems = [UIApplicationShortcutItem]()
        let objects = CoreDataManager.fetch(entity: "Feed", with: NSPredicate(format: "link != %@", [""]), and: [NSSortDescriptor(key: "lastUpdated", ascending: false)])
        for object in objects {
            if #available(iOS 9.1, *) {
                let shortcutItem = UIApplicationShortcutItem(type: (object as! Feed).title, localizedTitle: (object as AnyObject).title, localizedSubtitle: "", icon: UIApplicationShortcutIcon(templateImageName: "sectionsSelected"), userInfo: nil)
                application.shortcutItems?.append(shortcutItem)
            }
        }
    }

    func application(_: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler _: @escaping (Bool) -> Void) {
        switch shortcutItem.type {
        case "eu.fho-development.Simple-Feed.feed":
            let tabbarController = window?.rootViewController as! CustomTabBarController
            tabbarController.selectedIndex = 0
        default:
            let tabbarController = window?.rootViewController as! CustomTabBarController
            tabbarController.selectedIndex = 2
            let nav = tabbarController.viewControllers![2] as! UINavigationController

            CoreDataService.shared.performBackgroundTask { context in
                do {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Feed")
                    fetchRequest.predicate = NSPredicate(format: "title == %@", shortcutItem.type)
                    fetchRequest.fetchLimit = 1
                    let context = context
                    let objects = try (context.fetch(fetchRequest)) as? [Feed]
                    for object in objects! {
                        let controller = NewsFeedTVCFeed(feed: object)
                        controller.title = shortcutItem.type
                        nav.pushViewController(controller, animated: true)
                    }
                } catch let err { print(err) }
            }
        }
    }

    // MARK: - Split view

    func splitViewController(_: UISplitViewController, collapseSecondary _: UIViewController, onto _: UIViewController) -> Bool {
        if window?.rootViewController?.view.traitCollection.horizontalSizeClass == .regular {
            return false
        }
        return true
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}
