//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import SimpleFeedCore
import UIKit

extension NewsFeedTVC {
    @objc func refresh(_ sender: UIRefreshControl) {
        DispatchQueue.main.async {
            self.deleteOldArticles()
            self.refreshHeaderView()
            FetchManager.shared.fetchAll {
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
            tableView.backgroundView = EmptyFRCView(image: UIImage(named: "Feed"),
                                                    title: NSLocalizedString("NO_ARTICLES", comment: "No Feeds"),
                                                    subtitle: NSLocalizedString("ADD_FEED_DESCRIPTION", comment: "No Data Events"))
            tableView.separatorColor = .clear
        } else {
            tableView.backgroundView = nil
        }
    }

    func checkOffline() {
        let offlineView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30))
        let label = UILabel(frame: CGRect(x: 5, y: 5, width: view.frame.width, height: 20))
        label.text = NSLocalizedString("OFFLINE", comment: "Offline")
        label.textColor = FHColor.label.primary

        offlineView.addSubview(label)
        offlineView.backgroundColor = FHColor.fill.tertiary

        let networkStatus = Reachability.connectionStatus()
        switch networkStatus {
        case .offline, .unknown:
            tableView.tableHeaderView = offlineView
        default:
            tableView.tableHeaderView = nil
        }
    }

    func deleteOldArticles() {
        let oldestPostDate = Date().adding(days: -UserDefaults.standard.integer(forKey: SFUserDefaults.deleteArticleAfterDays))

        let deletePredicate = NSPredicate(format: "tagged == false AND lastRead == false AND date <= %@",
                                          argumentArray: [oldestPostDate])
        CoreDataManager.deleteObjects(entity: "Article", with: deletePredicate)
    }
}
