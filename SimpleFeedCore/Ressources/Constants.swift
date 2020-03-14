//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import UIKit

class Constants: NSObject {}

public struct userDefaults {
    public static let DELETE_ARTICLE_AFTER_DAYS = "DELETE_ARTICLE_AFTER_DAYS"
    public static let ACTIVATE_READER_AUTO = "autoActivateReader"
    public static let FIRST_START = "firstStart"
    public static let ICLOUD_ENABLED = "ICLOUD_ENABLED"
    public static let KEEP_LAST_READ = "KEEP_LAST_READ"
    public static let CLEARED_DATABASE = "CLEARED_DATABASE"

    public static let IMAGE_LOADING = "IMAGE_LOADING"
    public struct ImageLoading {
        public static let always = 1
        public static let onWifi = 2
        public static let never = 3
    }

    public static let TITLE_LINES = "TITLE_LINES"
    public static let PREVIEW_LINES = "PREVIEW_LINES"
    public static let FEEDS_VIEW = "feedsView"
    public static let GROUP_NEWS_FEED_BY_FEED = "GROUP_NEWS_FEED_BY_FEED"
}
