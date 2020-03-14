//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import UIKit

public class FetchManager: NSObject, RSSParserDelegate {
    public static let shared = FetchManager()

    private override init() {
        super.init()
    }

    private var fetching = false

    public func RSSParserError(_: RSSParser, error: String) {
        print(error)
    }

    public func fetch(_ abstractFeed: AbstractFeed, completion: (() -> Void)? = nil) {
        if let feed = abstractFeed as? Feed {
            fetchFeed(feed, completion: completion)
        } else if let group = abstractFeed as? Group {
            fetchGroup(group)
        } else {
            fatalError("Can't fetch " + abstractFeed.title)
        }
    }

    public func fetchAll(completion: (() -> Void)?) {
        let feeds = CoreDataManager.fetch(entity: "Feed") as! [Feed]
        fetch(feeds: feeds) {
            completion?()
        }
    }

    public func fetch(feeds: [Feed], completion: (() -> Void)?) {
        let numberOfFeeds = feeds.count
        var numberOfFetchedFeeds = 0
        for feed in feeds {
            fetchFeed(feed, completion: {
                numberOfFetchedFeeds += 1
                if numberOfFetchedFeeds >= numberOfFeeds {
                    self.fetching = false
                    completion?()
                }
            })
        }
        if numberOfFeeds == 0 {
            fetching = false
            completion?()
        }
    }

    private func fetchFeed(_ feed: Feed, completion: (() -> Void)?) {
        let lastUpdated: Date = Date().adding(days: -UserDefaults.standard.integer(forKey: userDefaults.DELETE_ARTICLE_AFTER_DAYS))
        let url = URL(string: feed.link)!
        let parser = RSSParser(url: url)
        parser.delegate = self
        parser.parse { finished in
            if finished {
                CoreDataService.shared.performBackgroundTask(task: { context in

                    print(url.absoluteString)

                    for item in parser.items {
                        guard let realFeed = context.object(with: feed.objectID) as? Feed else { return }

                        if realFeed.title == "" {
                            realFeed.title = parser.feedInfo.title
                            realFeed.lastEdited = Date()
                        }
                        realFeed.lastUpdated = Date()
                        realFeed.imageUrl = parser.feedInfo.imageUrl

                        if item.date.compare(lastUpdated) == .orderedDescending || item.date <= Date(timeIntervalSince1970: 0) {
                            if item.content != "" {
                                item.summary = item.content
                            }

                            if item.summary != "" {
                                let imageParser = HTMLParser(text: item.summary)
                                imageParser.parse {
                                    item.titleImage = imageParser.firstImageURL
                                    self.saveFeedItemToCoreData(item, feed: realFeed)
                                }

                            } else {
                                self.saveFeedItemToCoreData(item, feed: realFeed)
                            }
                        }
                    }
                })
            }
            completion?()
        }
    }

    private func fetchGroup(_: Group, completion: (() -> Void)? = nil) {
        completion?()
    }

    func saveFeedItemToCoreData(_ item: FeedItem, feed: Feed, context: NSManagedObjectContext = CoreDataService.shared.viewContext) {
        let (article, isNewArticle) = Article.getArticle(with: item.link, and: item.title, in: context)
        let itemDate = item.date > Date(timeIntervalSince1970: 0) ? item.date : Date()

        if isNewArticle {
            article.originalDate = itemDate
        }

        if article.summary != item.summary
            || article.title != article.title
            || article.titleImageUrl != item.titleImage {
            article.date = itemDate
            article.lastEdited = Date()
            article.summary = item.summary
            article.titleImageUrl = item.titleImage
        }

        if feed.managedObjectContext == article.managedObjectContext {
            article.publisher = feed
        } else if let feed = context.object(with: feed.objectID) as? Feed {
            article.publisher = feed
        }
    }
}
