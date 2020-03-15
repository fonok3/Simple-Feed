//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import Foundation
import SafariServices
import UIKit

class FeedCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, XMLParserDelegate {
    private let cellId = "cellId"

    var feeds: [Feed]?
    var items: [FeedItem] = [FeedItem]()

    var feed = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let clearButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(FeedCollectionViewController.refresh(_:)))
        navigationItem.rightBarButtonItem = clearButton

        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        collectionView?.alwaysBounceVertical = true

        collectionView?.registerClass(FeedItemCell.self, forCellWithReuseIdentifier: cellId)

//        clearData(self)
        if feed == "" {
            refresh(self)
        } else {
            fetchFeed(feed)
        }
    }

    func refresh(sender _: AnyObject) {
        feeds = fetchFeeds()!
        items = [FeedItem]()

        for feed in feeds! {
            fetchFeed(feed.link)
        }
    }

    func XMLParserError(parser _: XMLParser, error: String) {
        print(error)
    }

    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation _: UIInterfaceOrientation, duration _: NSTimeInterval) {
        collectionView?.reloadData()
    }

    func clearData(sender _: AnyObject) {
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate

        if let context = delegate?.managedObjectContext {
            do {
                let entityNames = ["Feed"]

                for entityName in entityNames {
                    let fetchRequest = NSFetchRequest(entityName: entityName)

                    let objects = try (context.executeFetchRequest(fetchRequest)) as? [NSManagedObject]

                    for object in objects! {
                        context.deleteObject(object)
                    }
                }

                try (context.save())

            } catch let err {
                print(err)
            }
        }
    }

    func fetchFeeds() -> [Feed]? {
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        if let context = delegate?.managedObjectContext {
            let request = NSFetchRequest(entityName: "Feed")

            do {
                return try context.executeFetchRequest(request) as? [Feed]

            } catch let err {
                print(err)
            }
        }

        return nil
    }

    func fetchFeed(url: String) {
        let parser = XMLParser(url: NSURL(string: url)!)
        parser.delegate = self
        parser.parse {
            for item in parser.items {
                item.publisher = parser.feedInfo
                self.items.append(item)
            }
            self.items.sortInPlace({ $0.date.compare($1.date) == .OrderedDescending })
            self.collectionView?.reloadData()
        }
    }

    func collectionView(collectionView _: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex _: Int) -> CGFloat {
        return 20
    }

    override func collectionView(collectionView _: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        let count = items.count
        return count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! FeedItemCell

        let item = items[indexPath.item]
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
        let bookmark: NSURL = NSURL(string: items[indexPath.row].link)!
        let safari = SFSafariViewController(URL: bookmark, entersReaderIfAvailable: true)
        presentViewController(safari, animated: true, completion: nil)
    }
}

class FeedItemCell: BaseCell {
    var titleImage = false

    var item: FeedItem? {
        didSet {
            titleLabel.text = item?.title
            titleImageView.imageFromContent((item?.content)!)

            let publisherDateLabelText = NSMutableString()
            publisherDateLabelText.appendString(item!.publisher.title)
            publisherDateLabelText.appendString("  •  ")
            publisherDateLabelText.appendString(item!.dateString)

            publisherDateLabel.text = publisherDateLabelText as String

            summaryLabel.text = item?.content.stringByConvertingHTMLToPlainText()
        }
    }

    let titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.font = UIFont.systemFontOfSize(18)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()

    let summaryLabel: UILabel = {
        let label = UILabel()
        label.text = "Summary"
        label.textColor = UIColor.darkGrayColor()
        label.font = UIFont.systemFontOfSize(14)
        label.numberOfLines = 0
        label.lineBreakMode = .ByWordWrapping
        return label
    }()

    let publisherDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Publisher"
        label.textColor = UIColor.darkGrayColor()
        label.font = UIFont.boldSystemFontOfSize(12)
        label.textColor = UIColor.rgb(155, green: 161, blue: 161)
        return label
    }()

    override func setupViews() {
        addSubview(titleImageView)

        setupContainerView()

        addSubview(summaryLabel)

        titleImageView.image = UIImage(named: "zuckprofile")

        addConstraintsWithFormat("H:|-8-[v0(100)]", views: titleImageView)
        addConstraintsWithFormat("H:|-8-[v0]-8-|", views: summaryLabel)
        addConstraintsWithFormat("V:|-8-[v0(75)]-8-[v1]-8-|", views: titleImageView, summaryLabel)
    }

    private func setupContainerView() {
        let containerView = UIView()
        addSubview(containerView)

        if !titleImage {
            addConstraintsWithFormat("H:|-116-[v0]-8-|", views: containerView)
        } else {
            addConstraintsWithFormat("H:|-8-[v0]-8-|", views: containerView)
        }
        addConstraintsWithFormat("V:|-8-[v0(83)]", views: containerView)

        containerView.addSubview(titleLabel)
        containerView.addSubview(publisherDateLabel)

        containerView.addConstraintsWithFormat("H:|[v0]|", views: titleLabel)
        containerView.addConstraintsWithFormat("H:|[v0]|", views: publisherDateLabel)

        containerView.addConstraintsWithFormat("V:|[v0][v1(14)]|", views: titleLabel, publisherDateLabel)
    }
}
