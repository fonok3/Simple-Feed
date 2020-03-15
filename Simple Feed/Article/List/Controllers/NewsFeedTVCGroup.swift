//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import SimpleFeedCore
import UIKit

class NewsFeedTVCGroup: NewsFeedTVC {
    var group: Group

    init(group: Group) {
        self.group = group

        super.init(style: .plain)

        title = group.title

        fetchRequest = Article.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "publisher IN %@ AND (read = false OR lastRead = true)", group.feeds!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        setUpReadButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = refreshFeedsControl
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        super.controller(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
        setUpReadButton()
    }
}
