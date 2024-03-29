//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import UIKit

protocol WebImageViewDelegate: AnyObject {
    func loadingError()
}

class WebImageView: UIImageView {
    weak var delegate: WebImageViewDelegate?

    private let loadingView: DottedLoadingView = {
        let view = DottedLoadingView()
        return view
    }()

    private var url: String = ""

    func loadImage(at url: String) {
        initializeImage(url)
    }

    func stopLoading() {
        task?.suspend()
        task = nil
    }

    private func setError(_: Bool = true) {
        DispatchQueue.main.async {
            self.image = nil
            self.stopLoading()
            self.loadingView.stopLoading()
            self.delegate?.loadingError()
        }
    }

    var task: URLSessionDataTask?

    private func initializeImage(_ imageUrl: String) {
        if imageUrl != "", imageUrl != url {
            guard let taskUrl = URL(string: imageUrl) else { setError(); return }

            url = imageUrl

            image = nil
            loadingView.startLoading()
            task?.suspend()

            task = URLSession.shared.dataTask(with: taskUrl, completionHandler: { (data, _, error) -> Void in

                guard error == nil else { self.setError(); return }
                guard let imageData = data else { self.setError(); return }

                if imageUrl == self.url {
                    DispatchQueue.main.async {
                        self.image = UIImage(data: imageData)
                        self.loadingView.stopLoading()
                    }
                }
            })
            task?.resume()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundColor = UIColor(displayP3Red: 0.95, green: 0.95, blue: 0.95, alpha: 1)

        contentMode = .scaleAspectFill
    }
}
