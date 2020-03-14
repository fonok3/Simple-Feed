//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import FHNetworking
import UIKit

extension SearchFeedTableViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let query = searchBar.text else { return }
        performSearchForText(query)
    }

    private func performSearchForText(_ text: String) {
        guard !text.isEmpty else {
            return
        }
        tableView.reloadData()
        currentTask?.cancel()
        let searchRequest = FeedlyNetworkRequest.search(text)
        currentTask = networkService.request(searchRequest) { [weak self] (result: Result<FeedlyResultsResponse, FHNetworkError>) in
            switch result {
            case let .success(response):
                self?.searchResults = response.results
            case let .failure(error):
                print(error)
            }
        }
    }
}
