//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData

extension NewsFeedCollectionViewController {
    func clearData(sender _: AnyObject) {
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate

        if let context = delegate?.managedObjectContext {
            do {
                let entityNames = ["FeedItem"]

                for entityName in entityNames {
                    let fetchRequest = NSFetchRequest(entityName: entityName)

                    let objects = try (context.executeFetchRequest(fetchRequest)) as? [NSManagedObject]

                    for object in objects! {
                        context.deleteObject(object)
                    }
                }
                try (context.save())

            } catch let err { print(err) }
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject _: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if controller == fetchedResultsControllerItems {
            if type == .Insert {
                blockOperations.append(NSBlockOperation(block: {
                    self.collectionView?.insertItemsAtIndexPaths([newIndexPath!])
                }))
            }
            if type == .Update {
                let cell = collectionView?.cellForItemAtIndexPath(indexPath!) as! ItemCell
                if cell.item!.seen {
                    cell.alpha = 0.5
                } else {
                    cell.alpha = 1
                }
            }
            if type == .Delete {
                blockOperations.append(NSBlockOperation(block: {
                    self.collectionView?.deleteItemsAtIndexPaths([indexPath!])
                }))
            }
        } else {
            refresh(UIRefreshControl())
        }
    }

    func controllerDidChangeContent(controller _: NSFetchedResultsController) {
        collectionView?.performBatchUpdates({
            for operation in self.blockOperations {
                operation.start()
            }

        }, completion: { _ in
        })
    }

    func oldestPostDate(maximumDaysBefore: Int) -> NSDate {
        let today: NSDate = NSDate()

        // Set up date components
        let dateComponents: NSDateComponents = NSDateComponents()
        dateComponents.day = -maximumDaysBefore

        // Create a calendar
        let gregorianCalendar: NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let oldestPostDate: NSDate = gregorianCalendar.dateByAddingComponents(dateComponents, toDate: today, options: NSCalendarOptions(rawValue: 0))!

        return oldestPostDate
    }
}
