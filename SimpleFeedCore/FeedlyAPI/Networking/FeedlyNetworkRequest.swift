//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import FHNetworking
import Foundation

public enum FeedlyNetworkRequest: FHNetworkRequest {
    case search(String)

    public var path: String {
        switch self {
        case .search:
            return "/v3/search/feeds"
        }
    }

    public var parameters: [URLQueryItem] {
        switch self {
        case let .search(query):
            return [
                URLQueryItem(name: "query", value: query)
            ]
        }
    }

    public var responseType: Any.Type? {
        switch self {
        case .search:
            return FeedlyResultsResponse.self
        }
    }
}
