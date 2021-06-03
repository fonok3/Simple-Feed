//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import FHNetworking
import Foundation
import SimpleFeedCore
import UIKit

extension FeedlyFeedResponse {
    fileprivate var link: String {
        return String(id.suffix(id.count - 5))
    }

    fileprivate var isAdded: Bool {
        (CoreDataManager.fetch(entity: "Feed",
                               with: NSPredicate(format: "link = %@", argumentArray: [self.link]),
                               in: CoreDataService.shared.viewContext) as? [Feed])?.first != nil
    }
}

public class SearchFeedTableViewController: UITableViewController {
    internal var networkService: FHNetworkService
    private let cellId = "FEED_RESULT_CELL_ID"

    internal var currentState: SearchState {
        if currentTask == nil {
            return .start
        }
        if currentTask?.state == .running {
            return .searching
        }
        return searchResults.count == 0 ? .noResults : .displayResults
    }

    internal var currentTask: URLSessionDataTask?

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.delegate = self
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false
        controller.searchBar.placeholder = NSLocalizedString("SEARCH_FOR_FEEDS", comment: "Search for Feeds")
        if #available(iOS 13.0, *) {
            controller.overrideUserInterfaceStyle = .dark
            controller.searchBar.overrideUserInterfaceStyle = .dark
        }
        return controller
    }()

    internal var searchResults: [FeedlyFeedResponse] = [FeedlyFeedResponse]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    public init(networkService: FHNetworkService = FeedlyNetworkService.shared) {
        self.networkService = networkService

        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
    }

    required init?(coder _: NSCoder) {
        networkService = FeedlyNetworkService.shared

        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        title = NSLocalizedString("ADD_FEED", comment: "Add Feed")

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))

        tableView.setEditing(true, animated: false)
    }

    // MARK: - Table view data source

    public override func numberOfSections(in _: UITableView) -> Int {
        return Sections.allCases.count
    }

    public override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section)! {
        case .info:
            return currentState == .displayResults ? 0 : 1
        case .results:
            return searchResults.count
        case .manual:
            guard !(searchController.searchBar.text ?? "").isEmpty else {
                return 0
            }
            return 1
        }
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellId)
            ?? UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: cellId)
        switch Sections(rawValue: indexPath.section)! {
        case .info:
            cell.textLabel?.text = textForInfoCell(at: currentState)
            cell.detailTextLabel?.text = nil
            return cell
        case .results:
            let entry = searchResults[indexPath.row]
            cell.textLabel?.text = entry.title
            cell.detailTextLabel?.text = entry.link
            return cell
        case .manual:
            cell.textLabel?.text = searchController.searchBar.text
            cell.detailTextLabel?.text = nil
            return cell
        }
    }

    private func textForInfoCell(at state: SearchState) -> String? {
        switch state {
        case .displayResults:
            return nil
        case .noResults:
            return NSLocalizedString("NO_RESULTS", comment: "No results")
        case .searching:
            return NSLocalizedString("SEARCHING", comment: "Searching")
        case .start:
            return NSLocalizedString("ENTER_SEARCH", comment: "Enter search")
        }
    }

    public override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections(rawValue: section)! {
        case .info:
            return nil
        case .results:
            return searchResults.count == 0 ? nil : NSLocalizedString("SUGGESTIONS", comment: "Suggestions")
        case .manual:
            guard !(searchController.searchBar.text ?? "").isEmpty else {
                return nil
            }
            return NSLocalizedString("ADD_MANUALLY", comment: "Add Feed manually")
        }
    }

    public override func tableView(_: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        switch Sections(rawValue: indexPath.section)! {
        case .info:
            return .none
        case .results:
            return searchResults[indexPath.row].isAdded ? .delete : .insert
        case .manual:
            return Feed.exists(with: searchController.searchBar.text) ? .delete : .insert
        }
    }

    public override func tableView(_ tableView: UITableView,
                                   commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .insert:
            switch Sections(rawValue: indexPath.section)! {
            case .info:
                break
            case .manual:
                guard let query = searchController.searchBar.text, let url = URL(string: query) else {
                    showErrorAlert()
                    return
                }
                let parser = RSSParser(url: url)
                parser.parse { result in
                    switch result {
                    case let .success(response):
                        let feed = response.feedInfo
                        self.add(feed: FeedlyFeedResponse.from(feedId: "feed/" + query, id: "feed/" + query, title: feed.title))
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    case .failure:
                        self.showErrorAlert()
                    }
                }
            case .results:
                add(feed: searchResults[indexPath.row])
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .delete:
            switch Sections(rawValue: indexPath.section)! {
            case .info:
                break
            case .manual:
                guard let query = searchController.searchBar.text else { return }
                remove(feed: FeedlyFeedResponse.from(feedId: "feed/" + query, id: "feed/" + query))
            case .results:
                remove(feed: searchResults[indexPath.row])
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case .none:
            break
        @unknown default:
            fatalError()
        }
    }

    private func showErrorAlert() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: NSLocalizedString("NO_VALID_URL", comment: "No valid URL"),
                message: NSLocalizedString("NO_VALID_URL_MESSAGE", comment: "No valid URL Message"), preferredStyle: .alert
            )
            let action = UIAlertAction(title: NSLocalizedString("OKAY", comment: "Okay"), style: .default, handler: nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    public func searchBarCancelButtonClicked(_: UISearchBar) {
        searchResults.removeAll()
        tableView.reloadData()
    }

    @objc func done() {
        dismiss(animated: true, completion: nil)
    }

    private func add(feed response: FeedlyFeedResponse) {
        let context = CoreDataService.shared.viewContext

        let feed = NSEntityDescription.insertNewObject(forEntityName: "Feed", into: context) as! Feed
        feed.title = response.title
        feed.link = response.link
        let date = Date().adding(days: -5)
        feed.lastUpdated = date

        let feeds = CoreDataManager.fetch(entity: "AbstractFeed")
        feed.index = NSNumber(value: feeds.count)

        CoreDataManager.saveContext()
    }

    private func remove(feed: FeedlyFeedResponse) {
        guard let feed = (CoreDataManager.fetch(entity: "Feed",
                                                with: NSPredicate(format: "link = %@", argumentArray: [feed.link]),
                                                in: CoreDataService.shared.viewContext) as? [Feed])?.first else {
            return
        }
        CoreDataManager.deleteFeed(feed: feed) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
