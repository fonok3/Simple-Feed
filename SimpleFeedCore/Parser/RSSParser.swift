//
// Stud.IP Connect
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import FHNetworking
import UIKit

public struct RSSResponse: Codable {
    var feedType: FeedType = .unknown
    var feedInfo: FeedInfo = FeedInfo()
    var articles: [FeedArticle] = [FeedArticle]()
}

public enum FeedType: Int, Codable {
    case unknown, RSS, RSS1, atom
}

public enum RSSError: Error {
    case network(FHNetworkError?)
    case parsing(Error?)
    case cancelled
}

public class RSSParser: NSObject, XMLParserDelegate {
    private let url: URL

    private var response = RSSResponse()

    private var processingArticle = FeedArticle()
    private var currentPath = ""
    private var currentText = ""
    private var currentElementAttributes = NSDictionary()

    private var completion: ((Result<RSSResponse, RSSError>) -> Void) = { _ in }

    private var xmlParser: XMLParser? {
        didSet {
            xmlParser?.delegate = self
        }
    }

    private var currentTask: URLSessionTask?

    init(url: URL) {
        self.url = url
    }

    func deleteObjects() {
        currentTask?.cancel()
        currentTask = nil
        xmlParser?.abortParsing()
        xmlParser = nil
        currentPath = ""
        currentText = ""
        response = RSSResponse()
        completion(.failure(.cancelled))
        completion = { _ in }
    }

    func parse(_ completion: @escaping (Result<RSSResponse, RSSError>) -> Void = { _ in }) {
        deleteObjects()
        self.completion = completion
        DispatchQueue.global(qos: .utility).async {
            if let xmlCode = try? Data(contentsOf: self.url) {
                self.xmlParser = Foundation.XMLParser(data: xmlCode)
                _ = self.xmlParser
            } else {
                completion(.failure(.network(nil)))
            }
        }
    }

    public func parserDidStartDocument(_: XMLParser) {}

    public func parser(_: XMLParser, didStartElement elementName: String, namespaceURI _: String?, qualifiedName _: String?, attributes attributeDict: [String: String] = [:]) {
        currentText = ""
        currentPath = currentPath + "/"
        currentPath = currentPath + elementName
        currentElementAttributes = attributeDict as NSDictionary

        if response.feedType == .unknown {
            if elementName == "rss" { response.feedType = .RSS }
            else if elementName == "rdf:RDF" { response.feedType = .RSS1 }
            else if elementName == "feed" { response.feedType = .atom }
        }

        if currentPath == "/rss/channel/item" || currentPath == "/rdf:RDF/item" || currentPath == "/feed/entry" {
            processingArticle = FeedArticle()
        }
    }

    public func parser(_: XMLParser, foundCharacters string: String) {
        currentText = currentText + string
    }

    public func parser(_: XMLParser, didEndElement elementName: String, namespaceURI _: String?, qualifiedName _: String?) {
        currentText = currentText.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n", with: "")

        var processed = false

        switch response.feedType {
        case .RSS:
            if !processed {
                switch currentPath {
                case "/rss/channel/item/title":
                    processingArticle.title = currentText
                    processed = true
                case "/rss/channel/item/link":
                    processingArticle.link = currentText
                    processed = true
                case "/rss/channel/item/pubDate":
                    processingArticle.date = Date.dateFromRFC822(string: currentText) ?? Date()
                    processed = true
                case "/rss/channel/item/description":
                    processingArticle.summary = currentText
                    processed = true
                case "/rss/channel/item/content":
                    processingArticle.content = currentText
                    processed = true
                case "/rss/channel/item/content:encoded":
                    processingArticle.content = currentText
                    processed = true
                case "/rss/channel/title":
                    response.feedInfo.title = currentText
                    processed = true
                case "/rss/channel/description":
                    response.feedInfo.feedDescription = currentText
                    processed = true
                case "/rss/channel/link":
                    response.feedInfo.link = currentText
                    processed = true
                case "/rss/channel/image/url":
                    response.feedInfo.imageUrl = currentText
                    processed = true
                default:
                    break
                }
            }
            if !processed, elementName == "item" {
                response.articles.append(processingArticle)
            }
        case .RSS1:
            if !processed {
                switch currentPath {
                case "/rdf:RDF/item/title":
                    processingArticle.title = currentText
                    processed = true
                case "/rdf:RDF/item/link":
                    processingArticle.link = currentText
                    processed = true
                case "/rdf:RDF/item/description":
                    processingArticle.summary = currentText
                    processed = true
                case "/rdf:RDF/item/content:encoded":
                    processingArticle.content = currentText
                    processed = true
                case "/rdf:RDF/item/dc:date":
                    processingArticle.date = Date.dateFromRFC3339(string: currentText) ?? Date()
                    processed = true
                case "/rdf:RDF/channel/title":
                    response.feedInfo.title = currentText
                    processed = true
                case "/rdf:RDF/channel/description":
                    response.feedInfo.feedDescription = currentText
                    processed = true
                case "/rdf:RDF/channel/link":
                    response.feedInfo.link = currentText
                    processed = true
                default:
                    break
                }
            }
            if !processed, elementName == "item" {
                response.articles.append(processingArticle)
            }
        case .atom:
            if !processed {
                switch currentPath {
                case "/feed/entry/title":
                    processingArticle.title = currentText
                    processed = true
                case "/feed/entry/link":
                    processingArticle.link = ((currentElementAttributes.object(forKey: "href") as AnyObject).description)!
                    processed = true
                case "/feed/entry/summary":
                    processingArticle.summary = currentText
                    processed = true
                case "/feed/entry/content":
                    processingArticle.content = currentText
                    processed = true
                case "/feed/entry/published":
                    processingArticle.date = Date.dateFromRFC3339(string: currentText) ?? Date()
                    processed = true
                case "/feed/title":
                    response.feedInfo.title = currentText
                    processed = true
                case "/feed/description":
                    response.feedInfo.feedDescription = currentText
                    processed = true
                case "/feed/link":
                    response.feedInfo.link = currentText
                    processed = true
                default:
                    break
                }
            }
            if !processed, elementName == "entry" {
                response.articles.append(processingArticle)
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
        DispatchQueue.main.async {
            self.completion(.failure(.parsing(parseError)))
        }
    }

    public func parserDidEndDocument(_: XMLParser) {
        DispatchQueue.main.async {
            self.completion(.success(self.response))
        }
    }
}
