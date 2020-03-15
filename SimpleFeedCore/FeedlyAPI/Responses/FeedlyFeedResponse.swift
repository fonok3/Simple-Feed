//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import Foundation

struct FeedlyFeedResponse: Codable {
    var feedId: String = "feed/"
    var id: String = ""
    var lastUpdated: Date = Date(timeIntervalSince1970: 0)

    var title: String = ""
    var description: String?

    var website: String = ""
    var subscribers: Int = 0

    var coverUrl: String? = ""
    var iconUrl: String? = ""
    var visualUrl: String? = ""
}
