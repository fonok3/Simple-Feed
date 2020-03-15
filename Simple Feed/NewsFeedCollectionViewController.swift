//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import SafariServices
import UIKit

private let reuseIdentifier = "Cell"

class NewsFeedCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate, XMLParserDelegate, UICollectionViewDelegateFlowLayout {
    lazy var fetchedResultsControllerItems: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "FeedItem")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()

    lazy var fetchedResultsControllerFeeds: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Feed")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: false)]

        if let feed = self.feedToFetch {
            fetchRequest.predicate = NSPredicate(format: "publisher.title = %@", feed.title)
        }

        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = delegate.managedObjectContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()

    let maximumPostAge = 2
    var oldestPostDate = NSDate()

    var blockOperations = [NSBlockOperation]()

    var feedToFetch: Feed?

    override func viewDidLoad() {
        super.viewDidLoad()

        oldestPostDate = oldestPostDate(maximumPostAge)

        if let feed = self.feedToFetch {
            fetchedResultsControllerItems.fetchRequest.predicate = NSPredicate(format: "publisher.title = %@", feed.title)
        }

//        clearData(self)

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.grayColor()
        refreshControl.addTarget(self, action: #selector(NewsFeedCollectionViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(refreshControl)

        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        collectionView?.alwaysBounceVertical = true

        // Register cell classes
        collectionView?.registerClass(ItemCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        do {
            try fetchedResultsControllerItems.performFetch()

        } catch let err {
            print(err)
        }

        refresh(UIRefreshControl())
    }

    func refresh(sender: UIRefreshControl) {
        oldestPostDate = oldestPostDate(maximumPostAge)

        var delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        if let context = delegate?.managedObjectContext {
            let request = NSFetchRequest(entityName: "FeedItem")

            var items = [FeedItemCoreData]()

            do {
                items = try context.executeFetchRequest(request) as! [FeedItemCoreData]

            } catch let err {
                print(err)
            }

            for item in items {
                if item.date.compare(oldestPostDate) == .OrderedAscending {
                    let path = fetchedResultsControllerItems.indexPathForObject(item)
                    context.deleteObject(fetchedResultsControllerItems.objectAtIndexPath(path!) as! NSManagedObject)
                }
            }
            do {
                try context.save()
            } catch let err { print(err) }
        }

        delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        if let context = delegate?.managedObjectContext {
            let request = NSFetchRequest(entityName: "Feed")

            var feeds = [Feed]()

            do {
                feeds = try context.executeFetchRequest(request) as! [Feed]

            } catch let err {
                print(err)
            }

            for feedInfo in feeds {
                fetchFeed(feedInfo.link, feed: feedInfo)
            }
            sender.endRefreshing()
        }
    }

    func XMLParserError(parser _: XMLParser, error: String) {
        print(error)
    }

    // MARK: UICollectionViewDataSource

    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation _: UIInterfaceOrientation, duration _: NSTimeInterval) {
        collectionView?.reloadData()
    }

    func collectionView(collectionView _: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex _: Int) -> CGFloat {
        return 20
    }

    override func collectionView(collectionView _: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if let count = fetchedResultsControllerItems.sections?[0].numberOfObjects {
            return count
        }
        return 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ItemCell

        let item = fetchedResultsControllerItems.objectAtIndexPath(indexPath) as! FeedItemCoreData
        cell.item = item

        return cell
    }

    func collectionView(collectionView _: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAtIndexPath _: NSIndexPath) -> CGSize {
        if UIDevice.currentDevice().orientation.isLandscape {
            return CGSizeMake(view.frame.width - 50, 190)
        } else {
            return CGSizeMake(view.frame.width, 150)
        }
    }

    override func collectionView(collectionView _: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        if let context = delegate?.managedObjectContext {
            let obj = fetchedResultsControllerItems.objectAtIndexPath(indexPath) as! FeedItemCoreData
            obj.seen = true

            do {
                try context.save()
            } catch let err {
                print(err)
            }
        }

        let bookmark: NSURL = NSURL(string: fetchedResultsControllerItems.objectAtIndexPath(indexPath).link)!
        let safari = SFSafariViewController(URL: bookmark, entersReaderIfAvailable: true)
        presentViewController(safari, animated: true, completion: nil)
    }

    func fetchFeed(url: String, feed: Feed) {
        var items = [FeedItemCoreData]()
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        if let context = delegate?.managedObjectContext {
            let fetchRequest = NSFetchRequest(entityName: "FeedItem")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "publisher.title = %@", feed.title)
            fetchRequest.fetchLimit = 1

            do {
                items = try (context.executeFetchRequest(fetchRequest)) as! [FeedItemCoreData]

            } catch let err {
                print(err)
            }
        }

        if let lastItem = items.first {
            let parser = XMLParser(url: NSURL(string: url)!)
            parser.delegate = self
            parser.parse {
                for item in parser.items {
                    if item.date.compare(lastItem.date) == .OrderedDescending, item.date.compare(self.oldestPostDate) == .OrderedDescending {
                        self.saveFeedItemToCoreData(item, feed: feed)
                    }
                }
                self.collectionView?.scrollsToTop
            }
        } else {
            let parser = XMLParser(url: NSURL(string: url)!)
            parser.delegate = self
            parser.parse {
                for item in parser.items {
                    if item.date.compare(self.oldestPostDate) == .OrderedDescending {
                        self.saveFeedItemToCoreData(item, feed: feed)
                    }
                }
            }
        }
    }

    func saveFeedItemToCoreData(item: FeedItem, feed: Feed) {
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        if let context = delegate?.managedObjectContext {
            let itemToSave = NSEntityDescription.insertNewObjectForEntityForName("FeedItem", inManagedObjectContext: context) as! FeedItemCoreData
            itemToSave.title = item.title
            itemToSave.date = item.date
            itemToSave.summary = item.summary
            itemToSave.content = item.content
            itemToSave.publisher = feed
            itemToSave.link = item.link
            itemToSave.seen = false

            print(itemToSave.publisher.title)

//            if item.content != "" {
//                itemToSave.titleImage = self.imageFromContent(itemToSave.content)
//            } else if item.summary != "" {
//                itemToSave.titleImage = self.imageFromContent(itemToSave.summary)
//            }
//
//            do {
//                try(context.save())
//            } catch let err {
//                print(err)
//            }

            var imageSourceParser: ParseForImageSource

            if item.content != "" {
                imageSourceParser = ParseForImageSource(text: item.content)
                imageSourceParser.parse {
                    itemToSave.titleImage = imageSourceParser.source
                    do {
                        try (context.save())
                    } catch let err {
                        print(err)
                    }
                    self.collectionView?.reloadData()
                }
            } else if item.summary != "" {
                imageSourceParser = ParseForImageSource(text: item.summary)
                imageSourceParser.parse {
                    itemToSave.titleImage = imageSourceParser.source
                    do {
                        try (context.save())
                    } catch let err {
                        print(err)
                    }
                    self.collectionView?.reloadData()
                }
            }
        }
    }
}
