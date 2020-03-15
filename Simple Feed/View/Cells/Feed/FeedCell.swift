//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import SimpleFeedCore
import UIKit

protocol FeedCellDelegate {
    func editButtonPressed(_ cell: FeedCell)
    func deleteButtonPressed(_ cell: FeedCell)
}

class FeedCell: UICollectionViewCell {
    var editing: Bool = false {
        didSet {
            editButton.isHidden = !editing
            deleteButton.isHidden = !editing || moving
            setSize()
        }
    }

    var moving: Bool = false {
        didSet {
            deleteButton.isHidden = !editing || moving
            setSize()
        }
    }

    func setSize() {
        if moving {
            UIView.animate(withDuration: 0.2, animations: {
                self.cardView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            })
        } else if editing {
            UIView.animate(withDuration: 0.2, animations: {
                self.cardView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.cardView.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        }
    }

    var delegate: FeedCellDelegate?

    // - Mark: Image loading

    func refreshImage() {
        if feed is Feed {
            var newImageUrl = (feed as? Feed)?.imageUrl ?? ""

            let articlesOfFeed = CoreDataManager.fetch(entity: "Article", with: NSPredicate(format: "publisher.link = %@", (feed as! Feed).link), and: [NSSortDescriptor(key: "date", ascending: false)]) as! [Article]

            for article in articlesOfFeed {
                if article.titleImageUrl != "" {
                    newImageUrl = article.titleImageUrl
                    break
                }
            }
            titleImageView.loadImage(at: newImageUrl)

        } else {
            let articlesOfFeed = CoreDataManager.fetch(entity: "Article", with: NSPredicate(format: "publisher IN %@ AND read = false", (feed as! Group).feeds!), and: [NSSortDescriptor(key: "date", ascending: false)]) as! [Article]
            for article in articlesOfFeed {
                if article.titleImageUrl != "" {
                    titleImageView.loadImage(at: article.titleImageUrl)
                    break
                }
            }
        }
    }

    var feed: AbstractFeed? {
        didSet {
            DispatchQueue.main.async {
                self.titleLabel.text = self.feed?.title
                self.iconImageView.image = UIImage(named: (self.feed is Group) ? "Folder" : "Feed")
            }

            refreshImage()
            layoutSubviews()
        }
    }

    let titleImageView: WebImageView = {
        let imageView = WebImageView()
        imageView.layer.masksToBounds = true
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = FHColor.label.secondary
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = FHColor.grouped.secondary
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = true
        return view
    }()

    let editButton: UIButton = {
        let button = UIButton()
        button.tintColor = FHColor.invertedLabelColor
        if let myImage = UIImage(named: "edit") {
            let tintableImage = myImage.withRenderingMode(.alwaysTemplate)
            button.setImage(tintableImage, for: .normal)
        }
        button.imageView?.contentMode = .scaleAspectFill
        button.imageView?.layer.masksToBounds = true
        button.backgroundColor = FHColor.fill.primary
        button.alpha = 0.7
        button.isHidden = true
        return button
    }()

    let deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "delete"), for: .normal)
        button.isHidden = true
        return button
    }()

    let readIndicator: UILabel = {
        let label = UILabel()
        label.text = "•"
        label.textColor = FHColor.readColor
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 30)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Feed"))
        imageView.tintColor = FHColor.label.secondary
        return imageView
    }()

    @objc func editButtonPressed() {
        delegate?.editButtonPressed(self)
    }

    @objc func deleteButtonPressed() {
        delegate?.deleteButtonPressed(self)
    }

    override func layoutSubviews() {
        cardView.removeConstraints(cardView.constraints)

        super.layoutSubviews()

        addSubview(cardView)

        addConstraintsWithFormat("H:|-2-[v0]-2-|", views: cardView)
        addConstraintsWithFormat("V:|-6-[v0]-6-|", views: cardView)

        cardView.addSubview(titleImageView)
        cardView.addConstraintsWithFormat("H:|[v0]|", views: titleImageView)

        cardView.addSubview(readIndicator)
        cardView.addConstraintsWithFormat("V:|[v0][v1(40)]|", views: titleImageView, readIndicator)
        cardView.addSubview(titleLabel)
        cardView.addConstraintsWithFormat("V:|[v0][v1(40)]|", views: titleImageView, titleLabel)

        cardView.addSubview(iconImageView)
        cardView.addConstraintsWithFormat("H:|-5-[v0(18)]-5-[v1]-5-[v2]-5-|", views: iconImageView, titleLabel, readIndicator)
        cardView.addConstraintsWithFormat("V:|[v0]-11-[v1(18)]-11-|", views: titleImageView, iconImageView)

        cardView.addSubview(editButton)
        cardView.addConstraintsWithFormat("H:|[v0]|", views: editButton)
        cardView.addConstraintsWithFormat("V:|[v0][v1(40)]|", views: editButton, titleLabel)

        addSubview(deleteButton)
        addConstraintsWithFormat("H:[v0(25)]|", views: deleteButton)
        addConstraintsWithFormat("V:|[v0(25)]", views: deleteButton)

        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
    }

    func startAnimation() {
        let duration = 0.25
        let delay = 0.0
        let options = UIView.KeyframeAnimationOptions.calculationModeLinear

        UIView.animateKeyframes(withDuration: duration, delay: delay, options: options, animations: {
            // each keyframe needs to be added here
            // within each keyframe the relativeStartTime and relativeDuration need to be values between 0.0 and 1.0

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1 / 3, animations: {
                self.cardView.transform = CGAffineTransform(rotationAngle: 1 / 25)
            })
            UIView.addKeyframe(withRelativeStartTime: 1 / 3, relativeDuration: 1 / 3, animations: {
                self.cardView.transform = CGAffineTransform(rotationAngle: -(1 / 25))
            })
            UIView.addKeyframe(withRelativeStartTime: 2 / 3, relativeDuration: 1 / 3, animations: {
                self.cardView.transform = CGAffineTransform(rotationAngle: 0)
            })

        }, completion: { _ in
            if self.moving {
                self.startAnimation()
            }

        })
    }
}
