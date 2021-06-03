//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import UIKit

class Constants: NSObject {}

public struct SFUserDefaults {
    public static let deleteArticleAfterDays = "DELETE_ARTICLE_AFTER_DAYS"
    public static let autoActivateReader = "autoActivateReader"
    public static let firstStart = "firstStart"
    public static let icloudEnabled = "ICLOUD_ENABLED"
    public static let keepLastRead = "KEEP_LAST_READ"
    public static let clearedDataBase = "CLEARED_DATABASE"

    public static let imageLoading = "IMAGE_LOADING"
    public struct ImageLoading {
        public static let always = 1
        public static let onWifi = 2
        public static let never = 3
    }

    public static let titleLines = "TITLE_LINES"
    public static let previewLines = "PREVIEW_LINES"
    public static let feedsView = "feedsView"
    public static let groupNewsFeedByFeed = "GROUP_NEWS_FEED_BY_FEED"
}
