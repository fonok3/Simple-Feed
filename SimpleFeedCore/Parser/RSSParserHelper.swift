//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import UIKit

class FeedItem: NSObject {
    var title: String
    var link: String
    var date: Date
    var summary: String
    var content: String
    var publisher: FeedInfo
    var titleImage: String

    override init() {
        title = ""
        link = ""
        date = Date(timeIntervalSince1970: 0)
        summary = ""
        content = ""
        publisher = FeedInfo()
        titleImage = ""
    }
}

class FeedInfo: NSObject {
    var title: String
    var link: String
    var feedDescription: String
    var imageUrl: String

    override init() {
        title = ""
        link = ""
        feedDescription = ""
        imageUrl = ""
    }
}
