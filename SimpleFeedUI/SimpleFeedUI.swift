//
//  SimpleFeedUI.swift
//  SimpleFeedUI
//
//  Created by Florian Herzog on 30.05.20.
//  Copyright © 2020 Florian Herzog. All rights reserved.
//

import Foundation

public extension Bundle {
    static var simpleFeedUI: Bundle {
        Bundle(for: SimpleFeedUI.self)
    }
}

public class SimpleFeedUI {
    #if DEBUG
    public var shared = SimpleFeedUI()
    #else
    public let shared = SimpleFeedUI()
    #endif
}
