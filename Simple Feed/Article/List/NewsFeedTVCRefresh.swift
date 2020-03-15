//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import SimpleFeedCore
import UIKit

extension NewsFeedTVC {
    @objc func refresh(_ sender: UIRefreshControl) {
        DispatchQueue.main.async {
            self.refreshHeaderView()

            switch AppDelegate.shareAppDelegate().refreshStatus {
            case .nothing:
                AppDelegate.shareAppDelegate().refreshStatus = .refreshAll
                self.deleteOldArticles()
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
                FetchManager.shared.fetchAll {
                    AppDelegate.shareAppDelegate().refreshStatus = .nothing
                    DispatchQueue.main.async {
                        sender.endRefreshing()
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }

            case .refreshSingleFeed:
                break
            default:
                print("Already refreshing")
                DispatchQueue.main.async {
                    sender.endRefreshing()
                }
            }
        }
    }

    func refreshHeaderView() {
        checkOffline()
        tableView.separatorColor = .clear
        if fetchedResultsController?.fetchedObjects?.count ?? 0 == 0 {
            tableView.backgroundView = EmptyFRCView(image: UIImage(named: "Feed"), title: NSLocalizedString("NO_ARTICLES", comment: "No Feeds"), subtitle: NSLocalizedString("ADD_FEED_DESCRIPTION", comment: "No Data Events"))
            tableView.separatorColor = .clear
        } else {
            tableView.backgroundView = nil
        }
    }

    func checkOffline() {
        let x = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30))
        let label = UILabel(frame: CGRect(x: 5, y: 5, width: view.frame.width, height: 20))
        label.text = NSLocalizedString("OFFLINE", comment: "Offline")
        label.textColor = FHColor.label.primary

        x.addSubview(label)
        x.backgroundColor = FHColor.fill.tertiary

        let networkStatus = Reachability.connectionStatus()
        switch networkStatus {
        case .offline, .unknown:

            tableView.tableHeaderView = x
        default:
            tableView.tableHeaderView = nil
        }
    }

    func deleteOldArticles() {
        let oldestPostDate = Date().adding(days: -UserDefaults.standard.integer(forKey: userDefaults.DELETE_ARTICLE_AFTER_DAYS))

        let deletePredicate = NSPredicate(format: "tagged == false AND lastRead == false AND date <= %@", argumentArray: [oldestPostDate])
        CoreDataManager.deleteObjects(entity: "Article", with: deletePredicate)
    }
}
