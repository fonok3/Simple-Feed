//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import SimpleFeedCore
import UIKit

@available(iOS 11.0, *)
extension NewsFeedTVC {
    override func tableView(_: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        if let article = fetchedResultsController?.object(at: indexPath) {
            let readAction = UIContextualAction(
                style: (article.read || article.tagged) ? .normal : .destructive,
                title: NSLocalizedString(article.read ? "UNREAD" : "READ", comment: "read")
            ) { _, _, completionHandler in
                completionHandler(true)

                article.read = !article.read
                article.lastEdited = Date()
                article.readDate = Date()
                article.lastRead = false
                article.publisher.lastEdited = article.publisher.lastEdited

                try? CoreDataService.shared.viewContext.saveAndWaitWhenChanged()
            }

            readAction.image = UIImage(named: article.read ? "unread" : "read")!.withRenderingMode(.alwaysTemplate)
            readAction.backgroundColor = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1)
            let configuration = UISwipeActionsConfiguration(actions: [readAction])
            return configuration
        }

        return UISwipeActionsConfiguration(actions: [UIContextualAction]())
    }

    override func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        if let obj = fetchedResultsController?.object(at: indexPath) {
            let readAction = UIContextualAction(
                style: .normal,
                title: NSLocalizedString(obj.tagged ? "UNTAG" : "TAG", comment: "tag")
            ) { _, _, completionHandler in
                completionHandler(true)
                obj.changeTaggingStatus()
            }

            readAction.image = UIImage(named: obj.tagged ? "labelSelected" : "label")!.withRenderingMode(.alwaysTemplate)
            readAction.backgroundColor = UIColor(red: 1.0, green: 149 / 255.0, blue: 0.05, alpha: 1.0)
            let configuration = UISwipeActionsConfiguration(actions: [readAction])
            return configuration
        }
        return UISwipeActionsConfiguration(actions: [UIContextualAction]())
    }
}

extension NewsFeedTVC {
    override func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if let obj = fetchedResultsController?.object(at: indexPath) {
            let readAction = UITableViewRowAction(
                style: .normal, title: NSLocalizedString(obj.read ? "UNREAD" : "READ", comment: "read")
            ) { _, _ in

                obj.changeReadStatus()
            }
            readAction.backgroundColor = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1)
            let tagAction = UITableViewRowAction(
                style: .normal, title: NSLocalizedString(obj.tagged ? "UNTAG" : "TAG", comment: "tag"), handler: { _, _ in
                    obj.changeTaggingStatus()
                }
            )
            tagAction.backgroundColor = UIColor(red: 1.0, green: 149 / 255.0, blue: 0.05, alpha: 1.0)
            return [readAction, tagAction]
        }
        return [UITableViewRowAction]()
    }
}
