//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import FHNetworking

public final class FeedlyNetworkService: FHNetworkService {
    public static var shared: FeedlyNetworkService = FeedlyNetworkService()

    public var baseUrl: String

    private init() {
        baseUrl = "https://cloud.feedly.com"
    }
}
