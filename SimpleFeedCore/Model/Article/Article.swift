//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import Foundation

public class Article: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }

    @NSManaged public var date: Date
    @NSManaged public var originalDate: Date
    @NSManaged public var lastEdited: Date
    @NSManaged public var lastRead: Bool
    @NSManaged public var link: String
    @NSManaged public var readDate: Date?
    @NSManaged public var summary: String
    @NSManaged public var tagged: Bool
    @NSManaged public var title: String
    @NSManaged public var titleImageUrl: String
    @NSManaged public var publisher: Feed
    @NSManaged public var read: Bool

    static func getArticle(with url: String, and title: String, in context: NSManagedObjectContext = CoreDataService.shared.viewContext) -> (Article) {
        return getArticle(with: url, and: title, in: context).article
    }

    static func getArticle(with url: String, and title: String, in context: NSManagedObjectContext = CoreDataService.shared.viewContext) -> (article: Article, new: Bool) {
        let fetchResults: [Article] = CoreDataService.shared.fetchData(predicate: NSPredicate(format: "link = %@ AND title = %@", argumentArray: [url, title]), curContext: context)

        if let article: Article = fetchResults.first {
            return (article: article, new: false)
        }

        let newArticle = Article(context: context)
        newArticle.link = url
        newArticle.title = title
        return (article: newArticle, new: true)
    }

    public var articleUpdated: Bool {
        guard originalDate > Date(timeIntervalSince1970: 0) else {
            return false
        }
        return originalDate != date && read
    }
}
