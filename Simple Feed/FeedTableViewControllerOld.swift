//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import SafariServices
import UIKit

// class FeedTableViewController: UITableViewController,MWFeedParserDelegate {
//    var managedObjectContext: NSManagedObjectContext? = nil
//
//    // Parsing
//    var feedParser:MWFeedParser?
//    var parsedItems:NSMutableArray = NSMutableArray()
//    var feedName:String = ""
//
//    // Displaying
//    var itemsToDisplay:NSArray = NSArray()
//    var formatter: NSDateFormatter?
//
//    override func viewDidLoad() {
//
//        // Super
//        super.viewDidLoad();
//
//        // Setup
//        self.title = "Loading...";
//        formatter = NSDateFormatter()
//        formatter!.dateStyle = .ShortStyle
//        formatter!.timeStyle = .ShortStyle
//
//        // Refresh button
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .Refresh, target: self, action: #selector(refresh))
//        // Parse
//        //	NSURL *feedURL = [NSURL URLWithString:@"http://images.apple.com/main/rss/hotnews/hotnews.rss"];
//        //	NSURL *feedURL = [NSURL URLWithString:@"http://feeds.mashable.com/Mashable"];
////        let feedURL = NSURL.init(string: "http://9to5mac.com/feed/")
////        feedParser = MWFeedParser.init(feedURL:feedURL)
////        feedParser!.delegate = self;
////        feedParser!.feedParseType = ParseTypeFull; // Parse feed info and all items
////        feedParser!.connectionType = ConnectionTypeAsynchronously;
////        feedParser!.parse()
//
//        var feeds = ["http://9to5mac.com/feed/","http://ifun.de/feed/","http://hasepost.de/feed/"]
//        for feed in feeds {
//            print(feed)
//            let parser = MWFeedParser.init(feedURL:NSURL.init(string:feed))
//            parser!.delegate = self;
//            parser!.feedParseType = ParseTypeFull; // Parse feed info and all items
//            parser!.connectionType = ConnectionTypeAsynchronously;
//            parser!.parse()
//        }
//
//
//    }
//
//    func refresh() {
//        self.title = "Refreshing...";
//        parsedItems.removeAllObjects()
//        feedParser!.stopParsing()
//        feedParser!.parse()
//        self.tableView.userInteractionEnabled = false;
//        self.tableView.alpha = 0.3;
//
//        let feedURL = NSURL.init(string: "http://ifun.de/feed/")
//        feedParser = MWFeedParser.init(feedURL:feedURL)
//        feedParser!.delegate = self;
//        feedParser!.feedParseType = ParseTypeFull; // Parse feed info and all items
//        feedParser!.connectionType = ConnectionTypeAsynchronously;
//        feedParser!.parse()
//    }
//
//    func updateTableWithParsedItems() {
//        self.itemsToDisplay = parsedItems.sortedArrayUsingDescriptors(NSArray.init(object: NSSortDescriptor.init(key: "date", ascending: false)) as! [NSSortDescriptor])
//        self.tableView.userInteractionEnabled = true;
//        self.tableView.alpha = 1;
//        self.tableView.reloadData()
//    }
//
//    //Mark: mark - MWFeedParserDelegate
//
//    func feedParserDidStart(parser:MWFeedParser) {
//        print("Parsed Feed Url: ",parser.url)
//    }
//
//    func feedParser(parser:MWFeedParser, didParseFeedInfo info:MWFeedInfo) {
//        print("Parsed Feed Info: " + info.title)
//        feedName = info.title
//        self.title = info.title
//    }
//
//    func feedParser(parser:MWFeedParser, didParseFeedItem item:MWFeedItem) {
//        print("Parsed Feed Item: " + item.title)
//        item.feed = ""
//        parsedItems.addObject(item)
//    }
//
//    func feedParserDidFinish(parser:MWFeedParser) {
//        print("Finished Parsing" + (parser.stopped ? " (Stopped)" : ""))
//        self.updateTableWithParsedItems()
//    }
//
//    func feedParser(parser:MWFeedParser, didFailWithError error:NSError) {
//        print("Finished Parsing with error: ", error)
////        if (parsedItems.count == 0) {
////            self.title = "Failed"; // Show failed message in title
////        } else {
//            // Failed but some items parsed, so show and inform of error
//            let alertController = UIAlertController(title: "Parsing Incomplete", message: "There was an error during the parsing of this feed. Not all of the feed items could parsed", preferredStyle: .Alert)
//
//        alertController.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
//            self.presentViewController(alertController, animated: true, completion: nil)
////        }
//        self.updateTableWithParsedItems()
//    }
//
//    // MARK: - Table View
//
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return itemsToDisplay.count;
//    }
//
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCellWithIdentifier("feedTableViewCellIdentifier", forIndexPath: indexPath) as! FeedsTableViewCell
//
//        // Configure the cell.
//        let item:MWFeedItem = itemsToDisplay[indexPath.row] as! MWFeedItem
//
//        // Process
//        let itemTitle = item.title.stringByConvertingHTMLToPlainText()
//        let itemSummary = item.summary.stringByConvertingHTMLToPlainText()
//
//        // Set
//        cell.titleLabel.font = UIFont.boldSystemFontOfSize(15)
//        cell.titleLabel.text = itemTitle;
//        let subtitle = NSMutableString()
//        if(item.date != nil) {
//            subtitle.appendFormat((formatter?.stringFromDate(item.date))!)
//        }
//        subtitle.appendString(", ")
//        subtitle.appendString(feedName);
//        cell.subTitleLabel.text = subtitle as String;
//        cell.contentLabel.text = itemSummary
//
//        if item.content != nil {
//
//            let htmlContent = item.content as NSString
//            var imageSource = ""
//
//
//            var regex = NSRegularExpression()
//            let rangeOfString = NSMakeRange(0, htmlContent.length)
//
//            do {
//                regex = try NSRegularExpression(pattern: "(<img.*?src=\")(.*?)(\".*?>)", options: .CaseInsensitive)
//            } catch let error {
//                print(error)
//            }
//
//            if htmlContent.length > 0 {
//                let match = regex.firstMatchInString(htmlContent as String, options: .WithoutAnchoringBounds, range: rangeOfString)
//
//                if match != nil {
//                    let imageURL = htmlContent.substringWithRange(match!.rangeAtIndex(2)) as String
//                    print(imageURL)
//
//                    if NSString(string: imageURL.lowercaseString).rangeOfString("feedburner").location == NSNotFound {
//                        imageSource = imageURL as String
//                    }
//
//                }
//            }
//
//            print(imageSource)
//
//            if imageSource != "" {
//                cell.articleImageView?.downloadedFrom(link: imageSource, contentMode: UIViewContentMode.ScaleAspectFit)
//            }
//
//        }
//
//        return cell
//    }
//
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//
//        let bookmark:NSURL = NSURL(string: itemsToDisplay[indexPath.row].link)!
//        let safari = SFSafariViewController(URL: bookmark, entersReaderIfAvailable: true)
//        print(bookmark)
//        presentViewController(safari, animated: true, completion: nil)
//    }
//
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
////        let nextController: ArticleViewController
////        if(UIDevice.currentDevice().userInterfaceIdiom != UIUserInterfaceIdiom.Pad) {
////            nextController = segue.destinationViewController as! ArticleViewController
////        } else {
////            let nextNavController:UINavigationController = segue.destinationViewController as! UINavigationController
////            nextController = nextNavController.viewControllers.first as! ArticleViewController
////        }
////
////        let x = self.tableView.indexPathForCell(sender as! UITableViewCell)?.item
////        print(x)
////
////        let entry:Entry = entries![x!] as Entry
////
////        nextController.entry = entry
//
//    }
//
//
// }
//
//
// extension String {
//    func firstMatchIn(string: NSString!, atRangeIndex: Int!) -> String {
//        var error : NSError?
//
//        var re = NSRegularExpression()
//
//        do {
//            re = try(NSRegularExpression(pattern: self, options: .CaseInsensitive))
//        } catch let error {
//            print(error)
//        }
//        let match = re.firstMatchInString(string as String, options: .WithoutAnchoringBounds, range: NSMakeRange(0, string.length))
//        return string.substringWithRange(match!.rangeAtIndex(atRangeIndex))
//    }
// }
