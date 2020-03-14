//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import CoreData
import SafariServices
import SimpleFeedCore
import UIKit

class FHSafariController: SFSafariViewController {
    var article: Article

    init(article: Article) {
        self.article = article
        let articleURL = URL(string: article.link)

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = UserDefaults.standard.bool(forKey: "autoActivateReader")

        super.init(url: articleURL!, configuration: config)

        preferredBarTintColor = FHColor.simpleFeedColor
        preferredControlTintColor = .white

    }

    lazy var previewActions: [UIPreviewActionItem] = {
        let readAction = UIPreviewAction(title: NSLocalizedString(self.article.read ? "UNREAD" : "READ", comment: "read"), style: .default) { _, _ in
            self.article.changeReadStatus()
        }

        let tagAction = UIPreviewAction(title: NSLocalizedString(self.article.tagged ? "UNTAG" : "TAG", comment: "tagging"), style: .default) { _, _ in
            self.article.changeTaggingStatus()
        }

        return [tagAction, readAction]
    }()

    override var previewActionItems: [UIPreviewActionItem] {
        return previewActions
    }
}
