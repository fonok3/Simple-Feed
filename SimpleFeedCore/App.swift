//
//  App.swift
//  SimpleFeedCore
//
//  Created by Florian Herzog on 02.03.20.
//  Copyright © 2020 Florian Herzog. All rights reserved.
//

import Foundation

public enum App {
    public static let infoDictionary = Bundle.main.infoDictionary!

    /// Display name of the application.
    public static let name = infoDictionary["Bundle full name"] as! String

    /// Bundle identifier of the application.
    public static let bundleIdentifier = infoDictionary["CFBundleIdentifier"] as! String

    /// Application group identifier used for sharing data between company apps.
    static let companyGroupIdentifier = "group.eu.herzog-de"

    /// Application group identifier used for sharing data between targets.
    static var appGroupIdentifier: String {
        switch bundleIdentifier {
        case "eu.fho-development.Simple-Feed":
            return "\(companyGroupIdentifier).Simple-Feed"
        default:
            fatalError("Cannot get app group identifier due to unknown bundle identifier")
        }
    }

    // MARK: - Persistence
    enum Persistence {
        static let modelName = "Simple_Feed"

        static let modelUrl = Bundle.simpleFeedCore.url(forResource: modelName, withExtension: "momd")!

        static let storeUrl = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: App.appGroupIdentifier)!
            .appendingPathComponent(modelName)
    }
}
