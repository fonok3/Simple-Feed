//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import SimpleFeedCore
import UIKit

class EditFeedVC: EditAbstractFeedVC<Feed, Group> {
    init(feed: Feed) {
        super.init(abstractFeed: feed)
        currentFeed = feed
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("EDIT_FEED", comment: "Edit Feed")
        urlTextField.text = currentFeed.link
        tableViewDescriptionLabel.text = NSLocalizedString("ADD_TO_GROUPS", comment: "Add to Group") + ":"
    }

    override func deleteFeed(_ sender: UIButton) {
        sender.isEnabled = false
        navigationItem.leftBarButtonItem?.isEnabled = false
        titleTextField.isEnabled = false
        print("Deleting Feed: " + currentFeed.link)

        CoreDataManager.deleteFeed(feed: currentFeed) {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }

    override func configure(_ cell: UITableViewCell, with abstractFeed: Group) {
        super.configure(cell, with: abstractFeed)
        if (abstractFeed.feeds?.contains(currentFeed))! {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) != nil {
            if let group = fetchedResultsController?.object(at: indexPath) {
                if !(group.feeds?.contains(currentFeed))! {
                    group.feeds = group.feeds?.adding(currentFeed) as NSSet?
                    CoreDataManager.saveContext()
                    tableView.reloadData()
                } else {
                    var set = group.feeds as! Set<Feed>
                    set.remove(currentFeed)
                    group.feeds = set as NSSet
                    CoreDataManager.saveContext()
                    tableView.reloadData()
                }
            }
        }
    }
}
