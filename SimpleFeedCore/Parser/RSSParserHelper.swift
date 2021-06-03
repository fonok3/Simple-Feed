//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import UIKit

public struct FeedArticle: Codable {
    var title: String = ""
    var link: String = ""
    var date: Date = Date(timeIntervalSince1970: 0)
    var summary: String = ""
    var content: String = ""
    var imageUrl: String = ""
}

public struct FeedInfo: Codable {
    public var title: String = ""
    public var link: String = ""
    public var feedDescription: String = ""
    public var imageUrl: String = ""
}
