//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import Foundation

public class Feed: AbstractFeed {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Feed> {
        return NSFetchRequest<Feed>(entityName: "Feed")
    }

    @NSManaged public var imageUrl: String
    @NSManaged public var lastUpdated: Date
    @NSManaged public var link: String
    @NSManaged public var articles: NSSet?
    @NSManaged public var groups: NSSet?
}

// MARK: Generated accessors for articles

extension Feed {
    @objc(addArticlesObject:)
    @NSManaged public func addToArticles(_ value: Article)

    @objc(removeArticlesObject:)
    @NSManaged public func removeFromArticles(_ value: Article)

    @objc(addArticles:)
    @NSManaged public func addToArticles(_ values: NSSet)

    @objc(removeArticles:)
    @NSManaged public func removeFromArticles(_ values: NSSet)
}

// MARK: Generated accessors for groups

extension Feed {
    @objc(addGroupsObject:)
    @NSManaged public func addToGroups(_ value: Group)

    @objc(removeGroupsObject:)
    @NSManaged public func removeFromGroups(_ value: Group)

    @objc(addGroups:)
    @NSManaged public func addToGroups(_ values: NSSet)

    @objc(removeGroups:)
    @NSManaged public func removeFromGroups(_ values: NSSet)
}

public extension Feed {
    static func exists(with url: String?) -> Bool {
        guard let url = url else {
            return false
        }
        return (CoreDataManager.fetch(entity: "Feed",
                                      with: NSPredicate(format: "link = %@", argumentArray: [url]),
                                      in: CoreDataService.shared.viewContext) as? [Feed])?.first != nil
    }
}
