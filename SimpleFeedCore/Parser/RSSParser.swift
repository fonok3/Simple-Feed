//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import UIKit

public protocol RSSParserDelegate {
    func RSSParserError(_ parser: RSSParser, error: String)
}

enum FeedType { case feedTypeUnknown, feedTypeRSS, feedTypeRSS1, feedTypeAtom }

public class RSSParser: NSObject, XMLParserDelegate {
    let url: URL
    var delegate: RSSParserDelegate?

    var feedType: FeedType = FeedType.feedTypeUnknown

    var items = [FeedItem]()
    var item = FeedItem()
    var currentPath = String()
    var feedInfo = FeedInfo()
    var currentText = String()
    var currentElementAttributes = NSDictionary()

    var formatter: DateFormatter?

    var handler: ((Bool) -> Void)?

    init(url: URL) {
        self.url = url
        currentText = ""
        formatter = DateFormatter()
        formatter!.dateStyle = .short
        formatter!.timeStyle = .short
    }

    func deleteObjects() {
        items.removeAll()
        feedInfo = FeedInfo()
        currentPath = ""
        handler = nil
    }

    func parse(_ handler: @escaping (Bool) -> Void) {
        self.handler = handler
        DispatchQueue.global().async {
            if let xmlCode = try? Data(contentsOf: self.url) {
                let parser = Foundation.XMLParser(data: xmlCode)
                parser.delegate = self

                if parser.parse() {}

            } else {
                let error = "Could not load feed: " + String(describing: self.url)
                self.delegate?.RSSParserError(self, error: error)
                if self.handler != nil {
                    self.handler!(false)
                }
            }
        }
    }

    public func parserDidStartDocument(_: XMLParser) {}

    public func parser(_: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName _: String?, attributes attributeDict: [String: String] = [:]) {
        currentText = ""
        currentPath = currentPath + "/"
        currentPath = currentPath + elementName
        currentElementAttributes = attributeDict as NSDictionary

        if feedType == FeedType.feedTypeUnknown {
            if elementName == "rss" { feedType = FeedType.feedTypeRSS }
            else if elementName == "rdf:RDF" { feedType = FeedType.feedTypeRSS1 }
            else if elementName == "feed" { feedType = FeedType.feedTypeAtom }
        }

        if currentPath == "/rss/channel/item" || currentPath == "/rdf:RDF/item" || currentPath == "/feed/entry" {
            item = FeedItem()
        }
    }

    public func parser(_: XMLParser, foundCharacters string: String) {
        currentText = currentText + string
    }

    public func parser(_: XMLParser, didEndElement elementName: String, namespaceURI _: String?, qualifiedName _: String?) {
        currentText = currentText.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n", with: "")

        var processed = false

        switch feedType {
        case .feedTypeRSS:
            if !processed {
                switch currentPath {
                case "/rss/channel/item/title":
                    item.title = currentText
                    processed = true
                case "/rss/channel/item/link":
                    item.link = currentText
                    processed = true
                case "/rss/channel/item/pubDate":
                    item.date = Date.dateFromRFC822(string: currentText) ?? Date()
                    processed = true
                case "/rss/channel/item/description":
                    item.summary = currentText
                    processed = true
                case "/rss/channel/item/content":
                    item.content = currentText
                    processed = true
                case "/rss/channel/item/content:encoded":
                    item.content = currentText
                    processed = true
                case "/rss/channel/title":
                    feedInfo.title = currentText
                    processed = true
                case "/rss/channel/description":
                    feedInfo.feedDescription = currentText
                    processed = true
                case "/rss/channel/link":
                    feedInfo.link = currentText
                    processed = true
                case "/rss/channel/image/url":
                    feedInfo.imageUrl = currentText
                    processed = true
                default:
                    break
                }
            }
            if !processed, elementName == "item" {
                items.append(item)
            }
        case .feedTypeRSS1:

            if !processed {
                switch currentPath {
                case "/rdf:RDF/item/title":
                    item.title = currentText
                    processed = true
                case "/rdf:RDF/item/link":
                    item.link = currentText
                    processed = true
                case "/rdf:RDF/item/description":
                    item.summary = currentText
                    processed = true
                case "/rdf:RDF/item/content:encoded":
                    item.content = currentText
                    processed = true
                case "/rdf:RDF/item/dc:date":
                    item.date = Date.dateFromRFC3339(string: currentText) ?? Date()
                    processed = true
                case "/rdf:RDF/channel/title":
                    feedInfo.title = currentText
                    processed = true
                case "/rdf:RDF/channel/description":
                    feedInfo.feedDescription = currentText
                    processed = true
                case "/rdf:RDF/channel/link":
                    feedInfo.link = currentText
                    processed = true
                default:
                    break
                }
            }
            if !processed, elementName == "item" {
                items.append(item)
            }
        case .feedTypeAtom:
            if !processed {
                switch currentPath {
                case "/feed/entry/title":
                    item.title = currentText
                    processed = true
                case "/feed/entry/link":
                    item.link = ((currentElementAttributes.object(forKey: "href") as AnyObject).description)!
                    processed = true
                case "/feed/entry/summary":
                    item.summary = currentText
                    processed = true
                case "/feed/entry/content":
                    item.content = currentText
                    processed = true
                case "/feed/entry/published":
                    item.date = Date.dateFromRFC3339(string: currentText) ?? Date()
                    processed = true
                case "/feed/title":
                    feedInfo.title = currentText
                    processed = true
                case "/feed/description":
                    feedInfo.feedDescription = currentText
                    processed = true
                case "/feed/link":
                    feedInfo.link = currentText
                    processed = true
                default:
                    break
                }
            }
            if !processed, elementName == "entry" {
                items.append(item)
            }
        default:
            break
        }

        var pathAsURL = URL(string: currentPath)
        pathAsURL = pathAsURL?.deletingLastPathComponent()
        currentPath = (pathAsURL?.absoluteString)!
        currentPath.remove(at: currentPath.index(before: currentPath.endIndex))
    }

    public func parser(_: XMLParser, parseErrorOccurred parseError: Error) {
        delegate?.RSSParserError(self, error: parseError.localizedDescription)
        DispatchQueue.main.async {
            self.handler?(false)
        }
    }

    public func parserDidEndDocument(_: XMLParser) {
        DispatchQueue.main.async {
            self.handler?(true)
        }
    }
}
