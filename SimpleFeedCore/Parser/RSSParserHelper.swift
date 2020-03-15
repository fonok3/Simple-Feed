//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import UIKit

struct FeedArticle: Codable {
    var title: String = ""
    var link: String = ""
    var date: Date = Date(timeIntervalSince1970: 0)
    var summary: String = ""
    var content: String = ""
    var imageUrl: String = ""
}

struct FeedInfo: Codable {
    var title: String = ""
    var link: String = ""
    var feedDescription: String = ""
    var imageUrl: String = ""
}
