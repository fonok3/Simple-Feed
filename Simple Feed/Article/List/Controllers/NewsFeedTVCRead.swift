//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import SimpleFeedCore
import UIKit

class NewsFeedTVCRead: NewsFeedTVC {
    init() {
        super.init(style: .plain)

        title = NSLocalizedString("READ_ARTICLES", comment: "Read Articles")

        fetchRequest = Article.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "read = %@ AND tagged = %@", argumentArray: [true, false])

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "readDate", ascending: false), NSSortDescriptor(key: "date", ascending: false)]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDeleteButton()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateUnreadLabel() {
        unreadLabel.text = String(fetchedResultsController!.fetchedObjects!.count) + " " + NSLocalizedString("READ", comment: "Read Articles")
    }

    @available(iOS 11.0, *)
    override func tableView(_: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let obj = fetchedResultsController?.object(at: indexPath)

        let readAction = UIContextualAction(style: obj!.read ? .destructive : .normal, title: NSLocalizedString(obj!.read ? "UNREAD" : "READ", comment: "read")) { _, _, completionHandler in
            completionHandler(true)
            obj?.changeReadStatus()
        }

        readAction.image = UIImage(named: obj!.read ? "unread" : "read")!.withRenderingMode(.alwaysTemplate)
        readAction.backgroundColor = UIColor(red: 0, green: 122 / 255, blue: 1, alpha: 1)
        let configuration = UISwipeActionsConfiguration(actions: [readAction])
        return configuration
    }
}
