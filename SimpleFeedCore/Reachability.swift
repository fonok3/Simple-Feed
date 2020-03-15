//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import Foundation
import SystemConfiguration

import UIKit

public enum ReachabilityStatus: CustomStringConvertible {
    public enum ReachabilityType: CustomStringConvertible {
        case wwan
        case wiFi

        public var description: String {
            switch self {
            case .wwan: return "WWAN"
            case .wiFi: return "WiFi"
            }
        }
    }

    case offline
    case online(ReachabilityType)
    case unknown

    public var description: String {
        switch self {
        case .offline: return "Offline"
        case let .online(type): return "Online (\(type))"
        case .unknown: return "Unknown"
        }
    }
}

public class Reachability {
    public static func connectionStatus() -> ReachabilityStatus {
        var zeroAddress = sockaddr_in()

        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, $0)
            }
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return .unknown
        }

        return ReachabilityStatus(reachabilityFlags: flags)
    }
}

extension ReachabilityStatus {
    init(reachabilityFlags flags: SCNetworkReachabilityFlags) {
        let connectionRequired = flags.contains(SCNetworkReachabilityFlags.connectionRequired)
        let isReachable = flags.contains(SCNetworkReachabilityFlags.reachable)
        let isWWAN = flags.contains(SCNetworkReachabilityFlags.isWWAN)

        if !connectionRequired, isReachable {
            if isWWAN {
                self = .online(.wwan)
            } else {
                self = .online(.wiFi)
            }
        } else {
            self = .offline
        }
    }
}
