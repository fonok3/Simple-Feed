//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import FHNetworking
import Foundation

enum FeedlyNetworkRequest: FHNetworkRequest {
    case search(String)

    var path: String {
        switch self {
        case .search:
            return "/v3/search/feeds"
        }
    }

    var parameters: [URLQueryItem] {
        switch self {
        case let .search(query):
            return [
                URLQueryItem(name: "query", value: query)
            ]
        }
    }

    var responseType: Any.Type? {
        switch self {
        case .search:
            return FeedlyResultsResponse.self
        }
    }
}
