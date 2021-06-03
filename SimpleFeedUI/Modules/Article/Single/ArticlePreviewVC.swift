//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import SimpleFeedCore
import UIKit

protocol ShareDelegate: class {
    func present(link: URL)
}

class ArticlePreviewVC: UIViewController {
    var article: Article

    weak var delegate: ShareDelegate?

    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)

        let formatter = DateFormatter()
        formatter.dateStyle = .short

        publisherLabel.text = formatter.string(from: article.date) + " - " + article.publisher.title
        titleLabel.text = article.title
        summaryLabel.text = article.summary.convertingHTMLToPlainText
    }

    var titleImage: UIImage?

    convenience init(article: Article, titleImage: UIImage) {
        self.init(article: article)
        self.titleImage = titleImage
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = FHColor.fill.tertiary

        // Do any additional setup after loading the view.

        layoutSubviews()
        image.image = titleImage

        image.contentMode = .scaleAspectFill
    }

    let image: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "PlaceHolderImage")
        return imageView
    }()

    let publisherLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .black
        label.layer.borderColor = FHColor.borderColor.cgColor
        label.layer.borderWidth = 4
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.text = "Test"
        label.layer.masksToBounds = true

        return label
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        return label
    }()

    let summaryLabel: UILabel = { let label = UILabel()
        label.text = "Summary"
        label.textColor = FHColor.label.secondary
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    let whiteView: UIView = {
        let view = UIView()
        view.backgroundColor = FHColor.fill.tertiary
        return view
    }()

    func layoutSubviews() {
        view.layoutSubviews()

        view.addSubview(image)
        if titleImage != nil {
            view.addConstraint(NSLayoutConstraint(item: image, attribute: .height, relatedBy: .equal,
                                                  toItem: view, attribute: .height, multiplier: 0.25, constant: 1))
        } else {
            view.addConstraintsWithFormat("V:|[v0(15)]", views: image)
        }
        view.addConstraintsWithFormat("H:|[v0]|", views: image)

        view.addSubview(whiteView)
        view.addConstraintsWithFormat("H:|[v0]|", views: whiteView)
        view.addConstraintsWithFormat("V:|[v0][v1]|", views: image, whiteView)

        view.addSubview(publisherLabel)
        view.addConstraintsWithFormat("V:[v0]-(-20)-[v1(40)]", views: image, publisherLabel)
        view.addConstraintsWithFormat("H:|-30-[v0]-30-|", views: publisherLabel)

        whiteView.addSubview(titleLabel)
        whiteView.addConstraintsWithFormat("H:|-8-[v0]-8-|", views: titleLabel)

        whiteView.addSubview(summaryLabel)
        whiteView.addConstraintsWithFormat("H:|-8-[v0]-8-|", views: summaryLabel)
        whiteView.addConstraintsWithFormat("V:|-28-[v0]-8-[v1]", views: titleLabel, summaryLabel)
    }

    lazy var previewActions: [UIPreviewActionItem] = {
        let readAction = UIPreviewAction(title: NSLocalizedString(self.article.read ? "UNREAD" : "READ", comment: "read"),
                                         style: .default) { _, _ in
            self.article.changeReadStatus()
        }

        let tagAction = UIPreviewAction(title: NSLocalizedString(self.article.tagged ? "UNTAG" : "TAG", comment: "tagging"),
                                        style: .default) { _, _ in
            self.article.changeTaggingStatus()
        }

        let shareAction = UIPreviewAction(title: NSLocalizedString("SHARE", comment: "Share"), style: .default) { _, _ in
            if let url = URL(string: self.article.link) {
                self.delegate?.present(link: url)
            }
        }

        return [tagAction, readAction, shareAction]
    }()

    override var previewActionItems: [UIPreviewActionItem] {
        return previewActions
    }
}
