//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import SafariServices
import SimpleFeedCore
import UIKit

enum ArticleStatus { case read, unread }
enum CellType { case imageCompact, imageRegular, text }

private let reuseIdentifierDefault = "IDENTIFIER_DEFAULT"
private let reuseIdentifierRegular = "IDENTIFIER_REGULAR"
private let reuseIdentifierCompact = "IDENTIFIER_COMPACT"

public class NewsFeedTVC: UITableViewController, NSFetchedResultsControllerDelegate, UIViewControllerPreviewingDelegate, ShareDelegate {
    // - Mark: Attributes
    var articleToPreview: Article?
    var fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()

    public override func viewDidLoad() {
        super.viewDidLoad()

        tableView.cellLayoutMarginsFollowReadableWidth = true

        refreshFeedsControl.addTarget(self, action: #selector(refresh(_:)), for: UIControl.Event.valueChanged)

        registerForPreviewing(with: self, sourceView: tableView)

        setUpCache()
        setUpTableView()

        tableView.isMultipleTouchEnabled = true

        refreshHeaderView()

        let nibArticleCellImage = UINib(nibName: "ArticleCell", bundle: .simpleFeedUI)
        tableView.register(nibArticleCellImage, forCellReuseIdentifier: cellIdentifier)
    }

    func lineHeight() -> CGFloat {
        let titleLines = CGFloat(UserDefaults.standard.integer(forKey: "TITLE_LINES"))
        let bodyLines = CGFloat(UserDefaults.standard.integer(forKey: "PREVIEW_LINES"))
        let titleHeight = titleLines * UIFont.preferredFont(forTextStyle: .headline).lineHeight + (titleLines - 1) * 2
        let bodyHeight = bodyLines * UIFont.preferredFont(forTextStyle: .body).lineHeight + (bodyLines - 1) * 2
        let const: CGFloat = 28
        let publisherLabelHeight = UIFont.preferredFont(forTextStyle: .subheadline).lineHeight

        return titleHeight + bodyHeight + const + publisherLabelHeight
    }

    public override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return lineHeight()
    }

    public override func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return lineHeight()
    }

    func setUpTitleView() {
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(-12, for: .default)
        navigationController?.navigationBar.addSubview(unreadLabel)

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.addConstraintsWithFormat("H:|[v0]|", views: unreadLabel)
            navigationController?.navigationBar.addConstraintsWithFormat("V:|-20-[v0]", views: unreadLabel)
        } else {
            unreadLabel.frame = CGRect(x: 0, y: 16, width: (navigationController?.navigationBar.frame.width)!, height: 20)
        }
    }

    func XMLParserError(_: XMLParser, error: String) {
        print(error)
    }

    func wiFiConnected() -> Bool {
        let networkStatus = Reachability.connectionStatus()
        switch networkStatus {
        case .unknown, .offline:
            return false
        case .online(.wwan):
            return false
        case .online(.wiFi):

            return true
        }
    }

    let unreadLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica Neue", size: 11)
        label.textColor = UIColor.white
        return label
    }()

    let refreshFeedsControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        return refreshControl
    }()

    public override func viewWillDisappear(_: Bool) {
        unreadLabel.removeFromSuperview()
        navigationController?.navigationBar.setTitleVerticalPositionAdjustment(0, for: .default)
    }

    public override func viewWillAppear(_: Bool) {
        setUpTitleView()
        updateUnreadLabel()
        tableView.reloadData()
    }

    public override func willAnimateRotation(to _: UIInterfaceOrientation, duration _: TimeInterval) {
        if #available(iOS 11.0, *) {} else {
            unreadLabel.frame = CGRect(x: 0, y: 16, width: (navigationController?.navigationBar.frame.width)!, height: 20)
        }
    }

    func setUpCache() {
        let memoryCapacity = 25 * 1024 * 1024
        let diskCapacity = 0
        let urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "myDiskPath")
        URLCache.shared = urlCache
    }

    func setUpTableView() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = FHColor.grouped.primary
    }

    func setUpDeleteButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "trash"), style: .plain,
                                                            target: self, action: #selector(deleteReadArticles(_:)))
    }

    func setUpReadButton() {
        if unreadArticles() == 0 {
            let readButton = UIBarButtonItem(image: UIImage(named: "readSelected"), style: .plain,
                                             target: self, action: #selector(NewsFeedTVC.readAll(_:)))
            readButton.isEnabled = false
            navigationItem.rightBarButtonItem = readButton

        } else {
            let readButton = UIBarButtonItem(image: UIImage(named: "read"), style: .plain,
                                             target: self, action: #selector(NewsFeedTVC.readAll(_:)))
            navigationItem.rightBarButtonItem = readButton
        }
    }

    func unreadArticles() -> Int {
        var unreadPredicate = NSPredicate(format: "read = %@", argumentArray: [false])
        if let predicate = fetchRequest.predicate {
            unreadPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [unreadPredicate, predicate])
        }

        let unreadArticles: [Article] = CoreDataService.shared.fetchData(predicate: unreadPredicate)
        return unreadArticles.count
    }

    func updateUnreadLabel() {
        unreadLabel.text = String(unreadArticles()) + " " + NSLocalizedString("UNREAD", comment: "Unread Articles")
    }

    @objc func deleteReadArticles(_: AnyObject) {
        let alert = UIAlertController(title: NSLocalizedString("DELETE_ARTICLES_HEADER", comment: "Delete Articles Header"),
                                      message: NSLocalizedString("DELETE_ARTICLES_MESSAGE", comment: "Delete Articles Message"),
                                      preferredStyle: .alert)

        let deleteAction = UIAlertAction(title: NSLocalizedString("DELETE", comment: "Delete"), style: .destructive) { _ in
            let deletePredicate = NSPredicate(format: "read == true")
            CoreDataManager.deleteObjects(entity: "Article", with: deletePredicate)
        }
        alert.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    var undoArticles = [Article]()

    @objc func undoLastOperation(_: AnyObject? = nil) {
        guard let articles = CoreDataManager.fetch(entity: "Article",
                                                   with: NSPredicate(format: "SELF IN %@",
                                                                     argumentArray: [undoArticles])) as? [Article] else { return }
        for article in articles {
            article.read = false
        }
        CoreDataManager.saveContext {
            self.setUpReadButton()
        }
    }

    @objc func readAll(_: AnyObject) {
        let unreadPredicate = NSPredicate(format: "read = %@", argumentArray: [false])
        guard let frcPred = fetchRequest.predicate else { return }

        CoreDataManager.markItemAsRead(with:
            NSCompoundPredicate(andPredicateWithSubpredicates: [frcPred, unreadPredicate])) { articles in
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.undo,
                                                                     target: self, action: #selector(self.undoLastOperation(_:)))
            self.undoArticles = articles
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

    // - Mark: Table View

    public override func numberOfSections(in _: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }

    public override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections![section].objects?.count ?? 0
    }

    private let cellIdentifier = "CELL_IDENTIFIER"

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    }

    public override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let article = fetchedResultsController?.object(at: indexPath), let cell = cell as? ArticleCell else { return }

        configureCell(cell, withObject: article)
    }

    public override func tableView(_: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt _: IndexPath) {
        guard let cell = cell as? ArticleCell else { return }
        cell.stopTasks()
    }

    func configureCell(_ cell: ArticleCell, withObject article: Article) {
        cell.type = useCell()
        cell.article = article
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let article = self.fetchedResultsController?.object(at: indexPath) {
            if URL(string: article.link) != nil {
                article.setRead()
                safariController = FHSafariController(article: article)
                present(safariController, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: NSLocalizedString("OPEN_FALIED", comment: "Open Failed"),
                                              message: NSLocalizedString("CANT_OPEN_URL",
                                                                         comment: "Cannot open Url. Please Refresh Data"),
                                              preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"),
                                              style: UIAlertAction.Style.default, handler: nil))

                present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: NSLocalizedString("OPEN_FALIED", comment: "Open Failed"),
                                          message: NSLocalizedString("CANT_OPEN_URL",
                                                                     comment: "Cannot open Url. Please Refresh Data"),
                                          preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"),
                                          style: UIAlertAction.Style.default, handler: nil))

            present(alert, animated: true, completion: nil)
        }
    }

    func present(link: URL) {
        let con = UIActivityViewController(activityItems: [link], applicationActivities: nil)
        present(con, animated: true)
    }

    // - Mark: Helper Methods

    func useCell() -> CellType {
        switch UserDefaults.standard.integer(forKey: SFUserDefaults.imageLoading) {
        case SFUserDefaults.ImageLoading.always:
            if view.traitCollection.horizontalSizeClass == .compact {
                return .imageCompact
            }
            return .imageRegular
        case SFUserDefaults.ImageLoading.onWifi:
            if wiFiConnected() {
                if view.traitCollection.horizontalSizeClass == .compact {
                    return .imageCompact
                }
                return .imageRegular
            }
            return .text
        default:
            return .text
        }
    }

    // - Mark: 3D Touch
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint)
        -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }

        let cellRect = tableView.rectForRow(at: indexPath).insetBy(dx: tableView.layoutMarginsGuide.layoutFrame.minX - 7, dy: 4)
        previewingContext.sourceRect = cellRect

        articleToPreview = fetchedResultsController?.object(at: indexPath)

        if let cell = tableView.cellForRow(at: indexPath) as? ArticleCell {
            if let image = cell.titleImageView.image {
                let con = ArticlePreviewVC(article: articleToPreview!, titleImage: image)
                con.delegate = self
                return con
            }
        }
        let co2 = ArticlePreviewVC(article: articleToPreview!)
        co2.delegate = self
        return co2
    }

    public func previewingContext(_: UIViewControllerPreviewing, commit _: UIViewController) {
        if URL(string: articleToPreview!.link) != nil {
            articleToPreview?.setRead()
            safariController = FHSafariController(article: articleToPreview!)
            present(safariController, animated: true, completion: nil)
        }
    }

    var internalFetchedResultsController: NSFetchedResultsController<Article>?

    @available(iOS 13.0, *)
    public override func tableView(_: UITableView,
                                   willPerformPreviewActionForMenuWith _: UIContextMenuConfiguration,
                                   animator: UIContextMenuInteractionCommitAnimating) {
        guard let article = articleToPreview, URL(string: article.link) != nil else {
            return
        }

        animator.addCompletion {
            article.setRead()
            self.safariController = FHSafariController(article: self.articleToPreview!)
            self.present(self.safariController, animated: true, completion: nil)
        }
    }

    var safariController: SFSafariViewController!

    @available(iOS 13.0, *)
    public override func tableView(_ tableView: UITableView,
                                   contextMenuConfigurationForRowAt indexPath: IndexPath, point _: CGPoint)
        -> UIContextMenuConfiguration? {
        guard let article = fetchedResultsController?.object(at: indexPath) else {
            return nil
        }

        let readAction = UIAction(title: NSLocalizedString(article.read ? "UNREAD" : "READ", comment: "read"),
                                  image: UIImage(systemName: article.read ? "checkmark.circle.fill" : "checkmark.circle")) { _ in
            article.changeReadStatus()
        }

        let tagAction = UIAction(title: NSLocalizedString(article.tagged ? "UNTAG" : "TAG", comment: "tagging"),
                                 image: UIImage(systemName: article.tagged ? "bookmark.fill" : "bookmark")) { _ in
            article.changeTaggingStatus()
        }

        let shareAction = UIAction(title: NSLocalizedString("SHARE", comment: "Share"),
                                   image: UIImage(systemName: "square.and.arrow.up")) { _ in
            if let url = URL(string: article.link) {
                self.present(link: url)
            }
        }

        let openAction = UIAction(title: NSLocalizedString("OPEN", comment: "Open"), image: UIImage(systemName: "safari")) { _ in
            if URL(string: self.articleToPreview!.link) != nil {
                self.articleToPreview?.setRead()
                self.safariController = FHSafariController(article: self.articleToPreview!)
                self.present(self.safariController, animated: true, completion: nil)
            }
        }

        let actions = [openAction, readAction, tagAction, shareAction]
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: { () -> UIViewController? in
                                              self.articleToPreview = self.fetchedResultsController?.object(at: indexPath)
                                              if let cell = tableView.cellForRow(at: indexPath) as? ArticleCell {
                                                  if let image = cell.titleImageView.image {
                                                      let con = ArticlePreviewVC(article: self.articleToPreview!, titleImage: image)
                                                      con.delegate = self
                                                      return con
                                                  }
                                              }
                                              let con = ArticlePreviewVC(article: self.articleToPreview!)
                                              con.delegate = self
                                              return con
                                          },
                                          actionProvider: { _ -> UIMenu? in
                                              UIMenu(title: "", image: nil, children: actions)
        })
    }
}
