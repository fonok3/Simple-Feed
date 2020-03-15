//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import UIKit

public class CoreDataManager: NSObject {
    public static func fetch(entity: String, with predicate: NSPredicate) -> [NSManagedObject] {
        return fetch(entity: entity, with: predicate, and: nil)
    }

    public static func fetch(entity: String) -> [NSManagedObject] {
        return fetch(entity: entity, with: nil, and: nil)
    }

    public static func fetch(entity: String, with predicate: NSPredicate?, and sortDescriptors: [NSSortDescriptor]? = nil, in context: NSManagedObjectContext = CoreDataService.shared.viewContext) -> [NSManagedObject] {
        var items = [NSManagedObject]()

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors

        do {
            items = try context.fetch(request) as! [NSManagedObject]
        } catch {
            print("Cant fetch")
        }
        return items
    }

    public static func deleteObjects(entity: String, with predicate: NSPredicate?, completion: (() -> Void)? = nil) {
        CoreDataService.shared.performBackgroundTask { context in
            let items = fetch(entity: entity, with: predicate, in: context)
            for item in items {
                context.delete(item)
            }
            completion?()
        }
    }

    public static func deleteFeed(feed: Feed, completion: (() -> Void)?) {
        deleteObjects(entity: "Feed", with: NSPredicate(format: "link = %@", argumentArray: [feed.link])) {
            completion?()
        }
    }

    public static func markItemAsRead(with predicate: NSPredicate?, completion: (([Article]) -> Void)? = nil) {
        var articles = [Article]()
        if predicate != nil {
            articles = fetch(entity: "Article", with: predicate!) as! [Article]
        } else {
            articles = fetch(entity: "Article") as! [Article]
        }

        articles.forEach { $0.setRead() }

        saveContext {
            completion?(articles)
        }
    }

    public static func saveContext(completion: (() -> Void)? = nil) {
        let context = CoreDataService.shared.viewContext
        if context.hasChanges {
            do {
                try context.save()
                completion?()
            } catch {}
        } else {
            completion?()
        }
    }
}
