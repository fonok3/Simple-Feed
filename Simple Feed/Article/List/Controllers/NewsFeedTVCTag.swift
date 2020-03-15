//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import SimpleFeedCore
import UIKit

class NewsFeedTVCTag: NewsFeedTVC {
    init() {
        super.init(style: .plain)

        title = NSLocalizedString("TAGGED_ARTICLES", comment: "Tagged Articles")
        fetchRequest = Article.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tagged = %@", argumentArray: [true])
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateUnreadLabel() {
        unreadLabel.text = String(fetchedResultsController!.fetchedObjects!.count) + " "
            + NSLocalizedString("TAGGED_ARTICLES", comment: "Tagged Articles")
    }

    @available(iOS 11.0, *)
    override func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        if let obj = fetchedResultsController?.object(at: indexPath) {
            let readAction = UIContextualAction(
                style: .destructive,
                title: NSLocalizedString(obj.tagged ? "UNTAG" : "TAG", comment: "tag")
            ) { _, _, completionHandler in
                completionHandler(true)
                obj.changeTaggingStatus()
            }

            readAction.image = UIImage(named: obj.read ? "labelSelected" : "label")!.withRenderingMode(.alwaysTemplate)
            readAction.backgroundColor = UIColor(red: 1.0, green: 149 / 255.0, blue: 0.05, alpha: 1.0)
            let configuration = UISwipeActionsConfiguration(actions: [readAction])
            return configuration
        }
        return UISwipeActionsConfiguration(actions: [UIContextualAction]())
    }

    @available(iOS 11.0, *)
    override func tableView(_: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        if let obj = fetchedResultsController?.object(at: indexPath) {
            let readAction = UIContextualAction(
                style: .normal, title: NSLocalizedString(obj.read ? "UNREAD" : "READ", comment: "read")
            ) { _, _, completionHandler in
                completionHandler(true)
                obj.changeReadStatus()
            }

            readAction.image = UIImage(named: obj.read ? "unread" : "read")!.withRenderingMode(.alwaysTemplate)
            readAction.backgroundColor = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1)
            let configuration = UISwipeActionsConfiguration(actions: [readAction])
            return configuration
        }

        return UISwipeActionsConfiguration(actions: [UIContextualAction]())
    }
}
