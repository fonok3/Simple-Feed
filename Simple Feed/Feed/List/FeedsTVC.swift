//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import SimpleFeedCore
import SimpleFeedUI
import UIKit

class FeedsTVC: UITableViewController, NSFetchedResultsControllerDelegate {
    fileprivate let rowId = "rowId"

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(_:)))
        navigationItem.rightBarButtonItem = addButton

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: rowId)

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }

    @objc func addButtonPressed(_ sender: UIBarButtonItem) {
        let feeds = CoreDataManager.fetch(entity: "Feed")
        if feeds.count < 3 {
            addFeed(sender)
        } else {
            showAddMenu(sender)
        }
    }

    func showAddMenu(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("ADD", comment: "add"), message: nil, preferredStyle: .actionSheet)
        let feedAction = UIAlertAction(title: "Feed", style: .default) { _ in
            self.addFeed(sender)
        }
        let groupAction = UIAlertAction(title: NSLocalizedString("GROUP", comment: "Group"), style: .default) { _ in
            self.addGroup(sender)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel, handler: nil)

        alert.addAction(feedAction)
        alert.addAction(groupAction)
        alert.addAction(cancelAction)

        alert.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem

        present(alert, animated: true, completion: nil)
    }

    func addFeed(_: Any) {
        let controller = SearchFeedTableViewController()
        let navCon = SFNavigationController(rootViewController: controller)
        navCon.modalPresentationStyle = .formSheet
        present(navCon, animated: true, completion: nil)
    }

    func addGroup(_: Any) {
        let group = NSEntityDescription.insertNewObject(forEntityName: "Group", into: CoreDataService.shared.viewContext) as! Group
        group.title = NSLocalizedString("UNTITLED", comment: "Untitled")
        group.lastEdited = Date()

        group.index = NSNumber(value: (fetchedResultsController?.fetchedObjects?.count)!)

        CoreDataManager.saveContext()
    }

    // MARK: - Table View

    override func numberOfSections(in _: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController?.sections![section]
        return sectionInfo!.numberOfObjects
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: rowId)
        cell.accessoryType = .detailButton

        let feed = fetchedResultsController?.object(at: indexPath)
        configureCell(cell, withObject: feed!)

        if feed?.index != NSNumber(value: indexPath.row) {
            feed?.index = NSNumber(value: indexPath.row)
            CoreDataManager.saveContext()
        }

        return cell
    }

    override func tableView(_: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if var feeds = fetchedResultsController?.fetchedObjects {
            let feed = feeds[sourceIndexPath.row]

            feeds.remove(at: sourceIndexPath.row)
            feeds.insert(feed, at: destinationIndexPath.row)

            var index = 0
            for f in feeds {
                f.index = NSNumber(value: index)
                index += 1
            }
            CoreDataManager.saveContext()
        }
    }

    func updateIndices() {
        if let feeds = fetchedResultsController?.fetchedObjects {
            fetchedResultsController?.delegate = nil

            var index = 0
            for f in feeds {
                f.index = NSNumber(value: index)
                index += 1
            }
            CoreDataManager.saveContext()

            fetchedResultsController?.delegate = self
        }
    }

    override func tableView(_: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let feed = fetchedResultsController?.object(at: indexPath) as? Feed {
                CoreDataManager.deleteFeed(feed: feed, completion: {
                    self.updateIndices()
                })
            } else if let group = fetchedResultsController?.object(at: indexPath) as? Group {
                CoreDataService.shared.performBackgroundTask { context in
                    context.delete(context.object(with: group.objectID))
                }

                updateIndices()
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withObject object: AbstractFeed) {
        cell.textLabel?.text = object.title

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true

        formatter.locale = Locale.current

        var subtitleString = ""

        if let feed = object as? Feed, let articles = CoreDataManager.fetch(entity: "Article", with: NSPredicate(format: "publisher.link = %@ AND read = %@", argumentArray: [feed.link, false])) as? [Article] {
            cell.detailTextLabel?.textColor = articles.count == 0 ? FHColor.label.secondary : FHColor.readColor
            subtitleString = String(articles.count) + " " + NSLocalizedString("UNREAD", comment: "Unread Articles")
        } else if let group = object as? Group, let articles = CoreDataManager.fetch(entity: "Article", with: NSPredicate(format: "publisher IN %@ AND read = %@", argumentArray: [group.feeds ?? NSSet(), false])) as? [Article] {
            cell.detailTextLabel?.textColor = articles.count == 0 ? FHColor.label.secondary : FHColor.readColor
            subtitleString = String(articles.count) + " " + NSLocalizedString("UNREAD", comment: "Unread Articles")
        } else {
            cell.detailTextLabel?.textColor = FHColor.readColor
            subtitleString = NSLocalizedString("NO_UNREAD_ARTICLES", comment: "No unread Articles")
        }

        if let feed = object as? Feed {
            subtitleString.append(
                ", " + NSLocalizedString("UPDATED", comment: "") + ": " + String(formatter.string(from: feed.lastUpdated as Date))
            )
        }
        cell.detailTextLabel?.text = subtitleString
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<AbstractFeed>? {
        if _fetchedResultsController != nil, _fetchedResultsController?.managedObjectContext == CoreDataService.shared.viewContext {
            return _fetchedResultsController!
        }

        let context = CoreDataService.shared.viewContext

        let fetchRequest = NSFetchRequest<AbstractFeed>(entityName: "AbstractFeed")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true), NSSortDescriptor(key: "title", ascending: true)]

        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController

        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return _fetchedResultsController!
    }

    var _fetchedResultsController: NSFetchedResultsController<AbstractFeed>?

    var itemToScrollTo: IndexPath?

    func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            itemToScrollTo = newIndexPath
            if let feed = anObject as? Feed {
                FetchManager.shared.fetch(feed)
            }
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!), let feed = anObject as? AbstractFeed {
                configureCell(cell, withObject: feed)
            }
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError()
        }
    }

    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        if let path = self.itemToScrollTo {
            tableView.scrollToRow(at: path, at: .bottom, animated: true)
            itemToScrollTo = nil
        }
    }

    override func tableView(_: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let feed = fetchedResultsController?.object(at: indexPath) {
            if feed is Feed {
                let controller = EditFeedVC(feed: feed as! Feed)
                show(controller, sender: self)
            } else {
                let controller = EditGroupVC(group: feed as! Group)
                show(controller, sender: self)
            }
        }
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !isEditing {
            if let feed = fetchedResultsController?.object(at: indexPath) as? Feed {
                let controller = NewsFeedTVCFeed(feed: feed)
                navigationController?.pushViewController(controller, animated: true)
            } else if let group = fetchedResultsController?.object(at: indexPath) as? Group {
                let controller = NewsFeedTVCGroup(group: group)
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}
