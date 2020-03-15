//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import Foundation

public extension Article {
    func changeTaggingStatus() {
        tagged = !tagged
        lastEdited = Date()
        try? managedObjectContext?.saveAndWaitWhenChanged()
    }

    func changeReadStatus() {
        setRead(!read)
    }

    func setRead(_ newRead: Bool = true) {
        read = newRead
        lastEdited = Date()
        readDate = Date()
        publisher.lastEdited = publisher.lastEdited
        publisher.groups?.forEach {
            ($0 as? Group)?.lastEdited = ($0 as? Group)?.lastEdited ?? Date()
        }

        let articles: [Article] = CoreDataService.shared.fetchData(predicate: NSPredicate(format: "lastRead = %@", argumentArray: [true]),
                                                                   curContext: managedObjectContext)
        for article in articles {
            article.lastRead = false
        }

        lastRead = true
        try? managedObjectContext?.saveAndWaitWhenChanged()
    }
}
