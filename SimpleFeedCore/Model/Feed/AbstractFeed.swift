//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import Foundation

public class AbstractFeed: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AbstractFeed> {
        return NSFetchRequest<AbstractFeed>(entityName: "AbstractFeed")
    }

    @NSManaged public var title: String
    @NSManaged public var lastEdited: Date
    @NSManaged public var index: NSNumber

    var section: String {
        if isKind(of: Feed.self) {
            return NSLocalizedString("FEEDS", comment: "Feeds")
        }
        return NSLocalizedString("GROUPS", comment: "Groups")
    }
}
