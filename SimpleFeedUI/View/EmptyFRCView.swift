//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import UIKit

class EmptyFRCView: UIView {
    init(image: UIImage?, title: String, subtitle: String) {
        super.init(frame: .zero)

        imageView.image = image
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = FHColor.label.secondary
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = FHColor.label.primary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = FHColor.label.secondary
        label.numberOfLines = 0
        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)

        addConstraintsWithFormat("V:[v0(45)]-16-[v1]-8-[v2]", views: imageView, titleLabel, subtitleLabel)
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal,
                                         toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

        addConstraint(NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal,
                                         toItem: self, attribute: .leftMargin, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .right, relatedBy: .equal,
                                         toItem: self, attribute: .rightMargin, multiplier: 1, constant: 0))

        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal,
                                         toItem: self, attribute: .leftMargin, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal,
                                         toItem: self, attribute: .rightMargin, multiplier: 1, constant: 0))

        addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .left, relatedBy: .equal,
                                         toItem: self, attribute: .leftMargin, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: subtitleLabel, attribute: .right, relatedBy: .equal,
                                         toItem: self, attribute: .rightMargin, multiplier: 1, constant: 0))
    }
}
