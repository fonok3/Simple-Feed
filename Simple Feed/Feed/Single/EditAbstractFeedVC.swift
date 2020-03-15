//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import SimpleFeedCore
import UIKit

class EditAbstractFeedVC<Element: AbstractFeed, SelectType: AbstractFeed>: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    var currentFeed: Element

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    init(abstractFeed: Element) {
        currentFeed = abstractFeed
        super.init(nibName: nil, bundle: nil)
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self as UITableViewDelegate
        tableView.dataSource = self as UITableViewDataSource

        extendedLayoutIncludesOpaqueBars = false
        edgesForExtendedLayout = UIRectEdge()
        view.backgroundColor = FHColor.fill.primary
        title = NSLocalizedString("EDIT_FEED", comment: "Edit Feed")
        deleteButton.addTarget(self, action: #selector(deleteFeed), for: .touchUpInside)

        titleTextField.text = currentFeed.title
        titleTextField.delegate = self
        urlTextField.text = ""

        setUpViews()
    }

    override func viewWillDisappear(_: Bool) {
        if titleTextField.text != nil, titleTextField.text != "" {
            let title = titleTextField.text ?? ""
            CoreDataService.shared.performBackgroundTask { context in
                guard let feed = context.object(with: self.currentFeed.objectID) as? Element else { return }
                feed.title = title
                feed.lastEdited = Date()
            }
        }
    }

    @objc func deleteFeed(_: UIButton) {
        CoreDataService.shared.performBackgroundTask { context in
            context.delete(context.object(with: self.currentFeed.objectID))
        }
        _ = navigationController?.popViewController(animated: true)
    }

    // - Mark: TextFieldDelegate
    func textFieldShouldReturn(_: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

    // - Mark: TableViewDataSource

    func numberOfSections(in _: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections![section].objects?.count ?? 0
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if let abstractFeed = fetchedResultsController?.object(at: indexPath) {
            configure(cell, with: abstractFeed)
        }

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {}

    func configureCellAt(_ indexPath: IndexPath) {
        let cell = UITableViewCell()
        if let abstractFeed = fetchedResultsController?.object(at: indexPath) {
            configure(cell, with: abstractFeed)
        }
    }

    func configure(_ cell: UITableViewCell, with abstractFeed: SelectType) {
        cell.textLabel?.text = abstractFeed.title
    }

    // - NSFetchedResultsControllerDelegate

    var fetchedResultsController: NSFetchedResultsController<SelectType>? {
        if _fetchedResultsController != nil, _fetchedResultsController?.managedObjectContext == CoreDataService.shared.viewContext {
            return _fetchedResultsController!
        }

        let context = CoreDataService.shared.viewContext

        let fetchRequest = NSFetchRequest<SelectType>(entityName: String(describing: SelectType.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true), NSSortDescriptor(key: "title", ascending: true)]

        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController

        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return _fetchedResultsController!
    }

    var _fetchedResultsController: NSFetchedResultsController<SelectType>?

    func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_: NSFetchedResultsController<NSFetchRequestResult>, didChange _: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .update:
            configureCellAt(indexPath!)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        default:
            break
        }
    }

    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func setUpViews() {
        view.addSubview(titleTextField)
        view.addSubview(deleteButton)
        view.addSubview(titleLabel)
        view.addSubview(urlTextField)
        view.addConstraintsWithFormat("H:[v0(70)]-8-[v1]", views: titleLabel, titleTextField)
        view.addConstraintsWithFormat("H:[v0(150)]", views: deleteButton)
        view.addConstraintsWithFormat("V:|-20-[v0(30)]", views: titleLabel)
        view.addConstraintsWithFormat("V:|-20-[v0(30)]-20-[v1]-30-[v2(30)]", views: titleTextField, urlTextField, deleteButton)
        view.addConstraint(NSLayoutConstraint(item: deleteButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 1))
        view.addSubview(tableViewDescriptionLabel)
        view.addSubview(tableView)
        view.addConstraintsWithFormat("V:[v0]-8-[v1]-8-[v2]-8-|", views: deleteButton, tableViewDescriptionLabel, tableView)
        view.addConstraintsWithFormat("H:|[v0]|", views: tableView)

        titleLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        titleTextField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true

        urlTextField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        urlTextField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true

        tableViewDescriptionLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
        tableViewDescriptionLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
    }

    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = FHColor.fill.secondary
        textField.tintColor = FHColor.label.secondary
        textField.textAlignment = .center
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        return textField
    }()

    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor.white, for: UIControl.State())
        button.backgroundColor = FHColor.simpleFeedRed
        button.setTitle(NSLocalizedString("DELETE", comment: "DELETE"), for: UIControl.State())
        return button
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("TITLE", comment: "Title") + ":"
        return label
    }()

    let urlTextField: UITextField = {
        let textField = UITextField()
        textField.isEnabled = false
        textField.textAlignment = .center
        return textField
    }()

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = true
        return tableView
    }()

    let tableViewDescriptionLabel: UILabel = {
        let label = UILabel()
        return label
    }()
}
