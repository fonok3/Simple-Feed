//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import SimpleFeedCore
import UIKit

extension NewsFeedTVC {
    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Article>? {
        if internalFetchedResultsController != nil,
            internalFetchedResultsController?.managedObjectContext == CoreDataService.shared.viewContext {
            return internalFetchedResultsController!
        }

        let context = CoreDataService.shared.viewContext
        let request: NSFetchRequest<Article> = Article.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        let aFetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil
        )
        aFetchedResultsController.delegate = self
        internalFetchedResultsController = aFetchedResultsController

        do {
            try aFetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        internalFetchedResultsController = aFetchedResultsController
        return internalFetchedResultsController!
    }

    func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            UIView.animate(withDuration: 0.002) {
                self.tableView.deleteRows(at: [indexPath!], with: .fade)
            }
        case .update:
            guard let cell = tableView.cellForRow(at: indexPath!) as? ArticleCell, let article = anObject as? Article else { return }
            configureCell(cell, withObject: article)

        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError()
        }
    }

    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        setUpReadButton()
        refreshHeaderView()
        updateUnreadLabel()
    }
}
