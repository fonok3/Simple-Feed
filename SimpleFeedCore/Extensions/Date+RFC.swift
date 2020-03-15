//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import Foundation

private let RFC822dateFormatsWithComma = ["EEE, d MMM yyyy HH:mm:ss zzz", "EEE, d MMM yyyy HH:mm zzz",
                                          "EEE, d MMM yyyy HH:mm:ss", "EEE, d MMM yyyy HH:mm"]
private let RFC822dateFormatsWithoutComma = ["d MMM yyyy HH:mm:ss zzz", "d MMM yyyy HH:mm zzz",
                                             "d MMM yyyy HH:mm:ss", "d MMM yyyy HH:mm"]

private let RFC3339dateFormatsWithComma = ["yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ", "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ",
                                           "yyyy'-'MM'-'dd'T'HH':'mm':'ss"]

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
}()

extension Date {
    static func dateFromRFC822(string: String) -> Date? {
        let formats = string.contains(",") ? RFC822dateFormatsWithComma : RFC822dateFormatsWithoutComma
        return dateFrom(string: string, with: formats)
    }

    static func dateFromRFC3339(string: String) -> Date? {
        let formats = RFC3339dateFormatsWithComma
        return dateFrom(string: string, with: formats)
    }

    private static func dateFrom(string: String, with formats: [String]) -> Date? {
        let string = string.uppercased()
        for dateFormat in formats {
            dateFormatter.dateFormat = dateFormat
            if let date = dateFormatter.date(from: string) {
                return date
            }
        }
        return nil
    }
}
