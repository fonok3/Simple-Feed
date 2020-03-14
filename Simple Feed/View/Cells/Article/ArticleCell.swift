//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import SimpleFeedCore
import UIKit

class ArticleCell: UITableViewCell, WebImageViewDelegate {
    var error = false

    func loadingError() {
        error = true
        titleImageView.isHidden = true
    }

    // MARK: - Attributes

    var type = CellType.text {
        willSet {}
        didSet {
            refreshConstraints()
        }
    }

    @IBOutlet var publisherLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var readLabel: UILabel!
    @IBOutlet var tagLabel: UILabel!

    @IBOutlet var titleImageView: WebImageView!

    @IBOutlet var cardView: UIView!
    var article: Article? {
        didSet {
            DispatchQueue.main.async {
                self.refreshCell()
            }
        }
    }

    // MARK: - Initialization

    override func layoutSubviews() {
        super.layoutSubviews()
        clipsToBounds = false

        cardView.layer.masksToBounds = false
        cardView.layer.cornerRadius = 5

        titleImageView.delegate = self
    }

    // MARK: - Displaying

    private func refreshCell() {
        error = false

        let titleLines = UserDefaults.standard.integer(forKey: "TITLE_LINES")
        let detailLines = UserDefaults.standard.integer(forKey: "PREVIEW_LINES")

        titleLabel.numberOfLines = titleLines

        titleLabel.isHidden = (titleLines == 0)
        detailLabel.isHidden = (detailLines == 0)

        titleLabel.text = article?.title

        titleImageView.alpha = (article?.read ?? false) ? 0.7 : 1

        publisherLabel.text = article?.publisher.title
        dateLabel.text = dateString(article?.date ?? Date())

        tagLabel.isHidden = !(article?.tagged ?? false)
        readLabel.isHidden = !(article?.read ?? false)

        refreshConstraints()

        if type != .text, let imageUrl = article?.titleImageUrl {
            titleImageView.loadImage(at: imageUrl)
        }

        if article?.summary != "" {
            let articleToCompare = article
            DispatchQueue.global(qos: .background).async {
                let plain = self.article?.summary.convertingHTMLToPlainText.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                let text = plain?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(CharacterSet.controlCharacters))
                DispatchQueue.main.async {
                    guard articleToCompare == self.article else { return }
                    self.detailLabel.text = text
                }
            }
        }
    }

    func refreshConstraints() {
        if (article?.titleImageUrl ?? "") != "", type != .text, !error {
            titleImageView.isHidden = false
        } else {
            titleImageView.isHidden = true
            titleImageView.image = nil
        }
    }

    // MARK: - Helper

    func dateString(_ date: Date) -> String {
        let now = Date()
        let passed = now.timeIntervalSince(date)
        let minute: Int = Int(passed) / 60
        if minute <= 1 {
            return NSLocalizedString("ONE_MINUTE_AGO", comment: "One Minute ago")
        }
        if minute < 60 {
            return String(format: NSLocalizedString("MINUTES_AGO", comment: "Minutes ago"), minute)
        }
        let hour = minute / 60
        if hour <= 1 {
            return NSLocalizedString("ONE_HOUR_AGO", comment: "One Hour ago")
        }
        if hour < 24 {
            return String(format: NSLocalizedString("HOURS_AGO", comment: "Hours ago"), hour)
        }
        let day = hour / 24
        if day <= 1 {
            return NSLocalizedString("ONE_DAY_AGO", comment: "One Day ago")
        }
        return String(format: NSLocalizedString("DAYS_AGO", comment: "Days ago"), day)
    }

    // MARK: - Life cycle

    func stopTasks() {
        titleImageView.stopLoading()
    }

    private let backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()

    private let selBackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()

    private func setViewColors() {
        textLabel?.backgroundColor = .clear
        detailTextLabel?.backgroundColor = .clear

        backgroundColor = UIColor.clear

        contentView.backgroundColor = .clear
        backgroundView = backView
        selectedBackgroundView = selBackView
    }

    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setHighlighted(selected, animated: animated)
    }

    open override func setHighlighted(_ highlighted: Bool, animated _: Bool) {
        if !isEditing, selectionStyle != .none {
            cardView.backgroundColor = highlighted ? FHColor.grouped.tertiary : FHColor.grouped.secondary
        } else {
            cardView.backgroundColor = FHColor.grouped.secondary
        }
        setViewColors()
    }
}

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return nil
        }
    }

    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }

    var convertingHTMLToPlainText: String {
        return (html2AttributedString?.string ?? "")
    }
}
