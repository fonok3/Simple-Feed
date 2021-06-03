//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import FHNetworking

public final class FeedlyNetworkService: FHNetworkService {
    public var session: URLSession = .shared

    public static var shared: FeedlyNetworkService = FeedlyNetworkService()

    public var baseUrl: String

    private init() {
        baseUrl = "https://cloud.feedly.com"
    }
}
