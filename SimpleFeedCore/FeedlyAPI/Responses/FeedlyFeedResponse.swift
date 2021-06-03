//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import Foundation

public struct FeedlyFeedResponse: Codable {
    var feedId: String = "feed/"
    public private(set) var id: String = ""
    var lastUpdated: Date = Date(timeIntervalSince1970: 0)

    public private(set) var title: String = ""
    var description: String?

    var website: String = ""
    var subscribers: Int = 0

    var coverUrl: String? = ""
    var iconUrl: String? = ""
    var visualUrl: String? = ""
}

public extension FeedlyFeedResponse {
    static func from(feedId: String, id: String, title: String = "") -> FeedlyFeedResponse {
        return FeedlyFeedResponse(feedId: feedId, id: id, title: title)
    }
}
