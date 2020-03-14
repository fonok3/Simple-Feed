//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import InAppSettingsKit
import SimpleFeedCore
import UIKit

class SettingsTVC: IASKAppSettingsViewController, IASKSettingsDelegate {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsTVC.settingDidChange(_:)), name: NSNotification.Name(rawValue: kIASKAppSettingChanged), object: nil)
        showDoneButton = false
        neverShowPrivacySettings = true
        delegate = self
        title = NSLocalizedString("SETTINGS", comment: "Settings")
    }

    @objc func settingDidChange(_ notification: Notification!) {
        switch notification.userInfo?.keys.first as! String {
        case "deleteReadAfterDays":
            let delete = UserDefaults.standard.integer(forKey: "deleteReadAfterDays")
            if delete == 0 {
                tabBarController?.viewControllers?.remove(at: 3)
            } else if tabBarController?.viewControllers?.count == 4 {
                let readNavigationController = SFNavigationController(rootViewController: NewsFeedTVCRead())
                readNavigationController.tabBarItem.image = UIImage(named: "read")
                readNavigationController.tabBarItem.selectedImage = UIImage(named: "readSelected")
                tabBarController?.viewControllers?.insert(readNavigationController, at: 3)
            }
        case "feedsView":
            switch UserDefaults.standard.integer(forKey: "feedsView") {
            case 2:
                let feedsController = FeedsTVC(style: .plain)
                feedsController.title = NSLocalizedString("FEEDS", comment: "Feeds")
                let feedsNavigationController = SFNavigationController(rootViewController: feedsController)
                feedsNavigationController.tabBarItem.image = UIImage(named: "sectionsSelected")
                tabBarController?.viewControllers![2] = feedsNavigationController
            default:
                let layout = UICollectionViewFlowLayout()
                layout.minimumInteritemSpacing = 10.0
                layout.minimumLineSpacing = 10.0
                let sectionsController = FeedsCVC(collectionViewLayout: layout)
                sectionsController.title = NSLocalizedString("FEEDS", comment: "Feeds")
                let sectionsNavigationController = SFNavigationController(rootViewController: sectionsController)
                sectionsNavigationController.tabBarItem.image = UIImage(named: "sectionsSelected")
                tabBarController?.viewControllers![2] = sectionsNavigationController
            }
        case "readSorting":
            let readNavigationController = SFNavigationController(rootViewController: NewsFeedTVCRead())
            readNavigationController.tabBarItem.image = UIImage(named: "read")
            readNavigationController.tabBarItem.selectedImage = UIImage(named: "readSelected")
            tabBarController?.viewControllers![3] = readNavigationController
        case userDefaults.KEEP_LAST_READ:
            let feedNavigationController = SFNavigationController(rootViewController: NewsFeedTVCUnread())
            feedNavigationController.tabBarItem.image = UIImage(named: "newsFeed")
            feedNavigationController.tabBarItem.selectedImage = UIImage(named: "Feed")
            tabBarController?.viewControllers![0] = feedNavigationController

//        case userDefaults.ICLOUD_ENABLED:
//            print("test")
//            if UserDefaults.standard.bool(forKey: userDefaults.ICLOUD_ENABLED) {
//                print("enabled")
//                AppDelegate.shareAppDelegate().ubiquityStoreManager.setCloudEnabledAndOverwriteCloudWithLocalIfConfirmed({ (setConfirmationAnswer: ((Bool) -> Void)?) in
//                    let alert = UIAlertController(title: NSLocalizedString("EXISTING_DATA", comment: "Existing Data"), message: NSLocalizedString("EXISTING_DATA_MESSAGE", comment: "Existing Data Message"), preferredStyle: .alert)
//                    let myAction = UIAlertAction(title: NSLocalizedString("USE_LOCAL_DATA", comment: "User local Data"), style: .default) { _ in
//                        setConfirmationAnswer!(true)
//                    }
//                    let theirsAction = UIAlertAction(title: NSLocalizedString("USE_CLOUD_DATA", comment: "User Cloud Data"), style: .default) { _ in
//                        setConfirmationAnswer!(false)
//                    }
//                    alert.addAction(myAction)
//                    alert.addAction(theirsAction)
//                    self.present(alert, animated: true, completion: nil)
//                })
//                print(UserDefaults.standard.bool(forKey: USMCloudEnabledKey))
//            } else {
//                AppDelegate.shareAppDelegate().ubiquityStoreManager.setCloudDisabledAndOverwriteLocalWithCloudIfConfirmed({ (setConfirmationAnswer: ((Bool) -> Void)?) in
//                    setConfirmationAnswer!(true)
//                })
//            }
        default:
            break
        }
    }

    // MARK: IASKAppSettingsViewControllerDelegate protocol

    func settingsViewControllerDidEnd(_: IASKAppSettingsViewController) {}

    func settingsViewController(_: IASKAppSettingsViewController!, buttonTappedFor _: IASKSpecifier!) {}

    override func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith _: MFMailComposeResult, error _: Error!) {
        controller.dismiss(animated: true, completion: nil)
    }
}
