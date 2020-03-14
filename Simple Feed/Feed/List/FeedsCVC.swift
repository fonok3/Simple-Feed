//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import SimpleFeedCore
import SimpleFeedUI
import UIKit

class FeedsCVC: UICollectionViewController, FeedCellDelegate, NSFetchedResultsControllerDelegate {
    // - Mark: Attributes
    fileprivate let cellIdSquare = "cellIdSquare"

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .always
        }

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        } else {
            // Fallback on earlier versions
        }

        navigationItem.title = "Feeds"

        setUpButtons()
        setUpCollectionView()
        setUpReordering()

        collectionView?.refreshControl = UIRefreshControl()
        collectionView?.refreshControl?.tintColor = FHColor.label.primary
        collectionView?.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)
    }

    @objc func refresh(_ sender: UIRefreshControl?) {
        FetchManager.shared.fetchAll {
            DispatchQueue.main.async {
                sender?.endRefreshing()
            }
        }
    }

    func setUpButtons() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(FeedsCVC.addButtonPressed(_:)))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = editButtonItem
    }

    func setUpCollectionView() {
        collectionView?.backgroundColor = FHColor.grouped.primary
        collectionView?.alwaysBounceVertical = true

        collectionView?.register(FeedCell.self, forCellWithReuseIdentifier: cellIdSquare)
    }

    func setUpReordering() {
        installsStandardGestureForInteractiveMovement = false

        let ges = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture))
        ges.minimumPressDuration = 0.75
        collectionView?.addGestureRecognizer(ges)
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
        let alert = UIAlertController(title: "Add", message: "Add Feed or Group?", preferredStyle: .actionSheet)
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

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        navigationItem.rightBarButtonItem?.isEnabled = !editing

        for cell in collectionView!.visibleCells {
            (cell as! FeedCell).editing = editing
        }
    }

    override func willAnimateRotation(to _: UIInterfaceOrientation, duration _: TimeInterval) {
        collectionView?.reloadData()
    }

    @objc func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAtIndexPath _: IndexPath) -> CGSize {
        var width = view.frame.width

        if #available(iOS 11.0, *) {
            width = width - view.safeAreaInsets.left
            width = width - view.safeAreaInsets.right
        }

        if traitCollection.horizontalSizeClass == .compact {
            width = ((width - 10) / 2)
        } else {
            width = ((width - 30) / 4)
        }
        return CGSize(width: width, height: width * 0.8)
    }

    override func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if let count = fetchedResultsController?.sections?[0].numberOfObjects {
            return count
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdSquare, for: indexPath) as! FeedCell
        let feed = fetchedResultsController?.object(at: indexPath)
        configureCell(cell, withObject: feed!)
        cell.delegate = self

        if feed?.index != NSNumber(value: indexPath.item) {
            feed?.index = NSNumber(value: indexPath.item)
            CoreDataManager.saveContext()
        }
        return cell
    }

    func configureCell(_ cell: FeedCell, withObject abstractFeed: AbstractFeed) {
        cell.feed = abstractFeed

        cell.delegate = self
        cell.editing = isEditing

        if abstractFeed is Feed {
            let articles = CoreDataManager.fetch(entity: "Article", with: NSPredicate(format: "publisher.link = %@ AND read = %@", argumentArray: [(abstractFeed as! Feed).link, false])) as! [Article]
            cell.readIndicator.isHidden = (articles.count == 0)
        } else {
            let articles = CoreDataManager.fetch(entity: "Article", with: NSPredicate(format: "publisher IN %@ AND read = %@", argumentArray: [(abstractFeed as! Group).feeds!, false])) as! [Article]
            cell.readIndicator.isHidden = (articles.count == 0)
        }
    }

    override func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentCell = collectionView?.cellForItem(at: indexPath) as! FeedCell

        if currentCell.feed is Feed {
            let controller = NewsFeedTVCFeed(feed: currentCell.feed as! Feed)
            show(controller, sender: nil)
        } else {
            let controller = NewsFeedTVCGroup(group: currentCell.feed as! Group)
            show(controller, sender: nil)
        }
    }

    override func collectionView(_: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if var feeds = fetchedResultsController?.fetchedObjects {
//            fetchedResultsController?.delegate = nil

            let feed = fetchedResultsController!.object(at: sourceIndexPath)

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

    // - Mark: FeedCellDelegate

    func editButtonPressed(_ cell: FeedCell) {
        if cell.feed is Feed {
            let controller = EditFeedVC(feed: cell.feed! as! Feed)
            show(controller, sender: self)
        } else {
            let controller = EditGroupVC(group: cell.feed as! Group)
            show(controller, sender: self)
        }
    }

    func deleteButtonPressed(_ cell: FeedCell) {
        if let feed = cell.feed as? Feed {
            CoreDataManager.deleteFeed(feed: feed, completion: {
                self.updateIndices()
            })
        } else {
            CoreDataService.shared.performBackgroundTask { context in
                context.delete(context.object(with: cell.feed!.objectID))
            }

            updateIndices()
        }
    }

    var cellX: FeedCell?

    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collectionView?.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                break
            }
            collectionView?.beginInteractiveMovementForItem(at: selectedIndexPath)
            if let cell = collectionView?.cellForItem(at: selectedIndexPath) as? FeedCell {
                cell.moving = true
                cellX = cell
            }
            setEditing(true, animated: true)
        case UIGestureRecognizerState.changed:
            collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            collectionView?.endInteractiveMovement()
            cellX?.moving = false
        default:
            collectionView?.cancelInteractiveMovement()
        }
    }

    // - Mark: FetchedResultsController

    var blockOperations = [BlockOperation]()

    var fetchedResultsController: NSFetchedResultsController<AbstractFeed>? {
        if _fetchedResultsController != nil, _fetchedResultsController?.managedObjectContext == CoreDataService.shared.viewContext {
            return _fetchedResultsController!
        }

        let context = CoreDataService.shared.viewContext

        let fetchRequest = NSFetchRequest<AbstractFeed>(entityName: "AbstractFeed")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true), NSSortDescriptor(key: "title", ascending: true)]

        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
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

    func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations = [BlockOperation]()
    }

    func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            blockOperations.append(BlockOperation(block: {
                self.itemToScrollTo = newIndexPath
                self.collectionView?.insertItems(at: [newIndexPath!])
                if let feed = anObject as? Feed {
                    FetchManager.shared.fetch(feed)
                }
            }))
        case .update:
            blockOperations.append(BlockOperation(block: {
                if let cell = self.collectionView?.cellForItem(at: indexPath!) as? FeedCell, let feed = self.fetchedResultsController?.object(at: indexPath!) {
                    self.configureCell(cell, withObject: feed)
                }
            }))
        case .delete:
            blockOperations.append(BlockOperation(block: {
                self.collectionView?.deleteItems(at: [indexPath!])
            }))
        case .move:
            break
        @unknown default:
            fatalError()
        }
    }

    var itemToScrollTo: IndexPath?

    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            for operation in self.blockOperations {
                operation.start()
            }

        }, completion: { _ in
            if let path = self.itemToScrollTo {
                self.collectionView?.scrollToItem(at: path, at: UICollectionView.ScrollPosition.bottom, animated: true)
                self.itemToScrollTo = nil
            }
        })
    }
}