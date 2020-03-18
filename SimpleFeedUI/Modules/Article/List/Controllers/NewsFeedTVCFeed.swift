//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import SimpleFeedCore
import UIKit

public class NewsFeedTVCFeed: NewsFeedTVC {
    var feed: Feed

    public init(feed: Feed) {
        self.feed = feed

        super.init(style: .plain)

        title = feed.title

        fetchRequest = Article.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "publisher.link = %@", argumentArray: [self.feed.link])

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        setUpReadButton()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refreshFeedsControl
    }

    @objc override func refresh(_ sender: UIRefreshControl) {
        FetchManager.shared.fetch(feed) { _ in
            DispatchQueue.main.async {
                sender.endRefreshing()
            }
        }
    }

    public override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any,
                                    at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        super.controller(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
        setUpReadButton()
    }

    @available(iOS 11.0, *)
    public override func tableView(_: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        let obj = fetchedResultsController?.object(at: indexPath)

        let readAction = UIContextualAction(
            style: obj!.read ? .normal : .normal,
            title: NSLocalizedString(obj!.read ? "UNREAD" : "READ", comment: "read")
        ) { _, _, completionHandler in
            completionHandler(true)
            obj?.changeReadStatus()
        }

        readAction.image = UIImage(named: obj!.read ? "unread" : "read")!.withRenderingMode(.alwaysTemplate)
        readAction.backgroundColor = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1)
        let configuration = UISwipeActionsConfiguration(actions: [readAction])
        return configuration
    }
}
