//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import SimpleFeedCore
import UIKit

class NewsFeedTVCUnread: NewsFeedTVC {
    init() {
        super.init(style: .plain)

        title = NSLocalizedString("NEWS_FEED", comment: "News Feed")
        fetchRequest = Article.fetchRequest()
        if UserDefaults.standard.bool(forKey: SFUserDefaults.keepLastRead) {
            fetchRequest.predicate = NSPredicate(format: "(read = %@ OR lastRead = %@ OR tagged = %@)",
                                                 argumentArray: [false, true, true])
        } else {
            fetchRequest.predicate = NSPredicate(format: "(read = %@)", argumentArray: [false])
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refresh(refreshFeedsControl)

        refreshControl = refreshFeedsControl

        setUpReadButton()
    }

    override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any,
                             at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        super.controller(controller, didChange: anObject, at: indexPath, for: type, newIndexPath: newIndexPath)
    }
}

extension UIView {
    func getSubview<T>(type _: T.Type) -> T? {
        let svs = subviews.flatMap { $0.subviews }
        let element = (svs.filter { $0 is T }).first

        return element as? T
    }
}
