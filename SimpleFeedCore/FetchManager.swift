//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import UIKit

public class FetchManager: NSObject {
    public static let shared = FetchManager()

    private override init() {
        super.init()
    }

    private var fetching = false

    public func fetch(_ abstractFeed: AbstractFeed, completion: @escaping ((Bool) -> Void) = { _ in }) {
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
            fetchFeed(feed, completion: { _ in
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

    private func fetchFeed(_ feed: Feed, completion: ((Bool) -> Void)?) {
        let lastUpdated: Date = Date().adding(days: -UserDefaults.standard.integer(forKey: SFUserDefaults.deleteArticleAfterDays))
        let url = URL(string: feed.link)!
        let parser = RSSParser(url: url)
        parser.parse { result in
            switch result {
            case let .success(response):
                CoreDataService.shared.performBackgroundTask(task: { context in
                    for item in response.articles {
                        guard let realFeed = context.object(with: feed.objectID) as? Feed else { return }

                        if realFeed.title == "" {
                            realFeed.title = response.feedInfo.title
                            realFeed.lastEdited = Date()
                        }
                        realFeed.lastUpdated = Date()
                        realFeed.imageUrl = response.feedInfo.imageUrl

                        if item.date.compare(lastUpdated) == .orderedDescending || item.date <= Date(timeIntervalSince1970: 0) {
                            let summary = !item.content.isEmpty ? item.content : item.summary
                            if summary != "" {
                                let imageParser = HTMLParser(text: summary)
                                imageParser.parse {
                                    let url = imageParser.firstImageURL
                                    self.saveFeedItemToCoreData(item, feed: realFeed, image: url)
                                }
                            } else {
                                self.saveFeedItemToCoreData(item, feed: realFeed)
                            }
                        }
                    }
                    completion?(true)
                })
            case .failure:
                completion?(false)
            }
        }
    }

    private func fetchGroup(_: Group, completion: (() -> Void)? = nil) {
        completion?()
    }

    func saveFeedItemToCoreData(_ item: FeedArticle, feed: Feed, image: String? = nil,
                                context: NSManagedObjectContext = CoreDataService.shared.viewContext) {
        let (article, isNewArticle) = Article.getArticle(with: item.link, and: item.title, in: context)
        let itemDate = item.date > Date(timeIntervalSince1970: 0) ? item.date : Date()

        if isNewArticle {
            article.originalDate = itemDate
        }

        if article.summary != item.summary
            || article.title != article.title
            || article.titleImageUrl != item.imageUrl {
            article.date = itemDate
            article.lastEdited = Date()
            article.summary = item.summary
            article.titleImageUrl = image ?? item.imageUrl
        }

        if feed.managedObjectContext == article.managedObjectContext {
            article.publisher = feed
        } else if let feed = context.object(with: feed.objectID) as? Feed {
            article.publisher = feed
        }
    }
}
