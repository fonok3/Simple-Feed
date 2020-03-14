//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import UIKit

protocol HTMLParserDelegate {
    func HTMLParserError(_ parser: HTMLParser, error: String)
}

class HTMLParser: NSObject, XMLParserDelegate {
    var delegate: HTMLParserDelegate?

    var feedType: FeedType = FeedType.feedTypeUnknown

    var currentElementAttributes = NSDictionary()

    var firstImageURL: String
    var text: String

    var handler: (() -> Void)?

    init(text: String) {
        self.text = text
        firstImageURL = ""
    }

    func parse(_ handler: @escaping () -> Void) {
        self.handler = handler

        DispatchQueue.global().async {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }

            if let xmlCode: Data = ("<xml>" + self.text + "</xml>").data(using: String.Encoding.utf8) {
                let parser = XMLParser(data: xmlCode)
                parser.delegate = self

                if parser.parse() {
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                }
            }

            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }

    func parser(_: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName _: String?, attributes attributeDict: [String: String] = [:]) {
        currentElementAttributes = attributeDict as NSDictionary
        if elementName == "img", firstImageURL == "" {
            if let x = (currentElementAttributes["src"] as AnyObject).description, URL(string: x) != nil {
                firstImageURL = x
            }
        }
    }

    func parser(_: XMLParser, foundCharacters _: String) {}

    func parser(_: XMLParser, didEndElement _: String, namespaceURI _: String?, qualifiedName _: String?) {}

    func parser(_: XMLParser, parseErrorOccurred parseError: Error) {
        delegate?.HTMLParserError(self, error: parseError.localizedDescription)
        DispatchQueue.main.async {
            self.handler?()
        }
    }

    func parserDidEndDocument(_: XMLParser) {
        DispatchQueue.main.async {
            self.handler?()
        }
    }
}
