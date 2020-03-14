//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import SimpleFeedCore
import UIKit

class EditGroupVC: EditAbstractFeedVC<Group, Feed> {
    init(group: Group) {
        super.init(abstractFeed: group)
        currentFeed = group
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("EDIT_GROUP", comment: "Edit Group")
        tableViewDescriptionLabel.text = NSLocalizedString("ADD_FEEDS", comment: "Add Feed") + ":"
    }

    override func configure(_ cell: UITableViewCell, with abstractFeed: Feed) {
        super.configure(cell, with: abstractFeed)
        if (abstractFeed.groups?.contains(currentFeed))! {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) != nil {
            if let feed = fetchedResultsController?.object(at: indexPath) {
                if !(feed.groups?.contains(currentFeed))! {
                    feed.groups = feed.groups?.adding(currentFeed) as NSSet?
                    try? CoreDataService.shared.viewContext.saveAndWaitWhenChanged()
                    tableView.reloadData()
                } else {
                    var set = feed.groups as! Set<Group>
                    set.remove(currentFeed)
                    feed.groups = set as NSSet
                    try? CoreDataService.shared.viewContext.saveAndWaitWhenChanged()
                    tableView.reloadData()
                }
            }
        }
    }
}
