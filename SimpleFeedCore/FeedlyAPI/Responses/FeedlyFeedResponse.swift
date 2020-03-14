//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import Foundation

struct FeedlyFeedResponse: Codable {
    var feedId: String
    var id: String
    var lastUpdated: Date

    var title: String
    var description: String?

    var website: String
    var subscribers: Int

    var coverUrl: String?
    var iconUrl: String?
    var visualUrl: String?
}
