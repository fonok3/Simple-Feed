//
// Simple Feed
// Copyright © 2020 Florian Herzog. All rights reserved.
//

import UIKit

public final class FHColor {
    // MARK: Label Colors

    public static var label: FHGradedColor = FHLabelColors()
    public static var invertedLabelColor: UIColor = UIColor(named: "invertedLabelColor", in: Bundle.main, compatibleWith: nil)!

    // MARK: Fill Colors

    public static var fill: FHGradedColor = FHBackgroundColors()

    // MARK: Grouped Colors

    public static var grouped: FHGradedColor = FHBackgroundGroupedColors()

    public static var simpleFeedRed: UIColor = UIColor(named: "simpleFeedRed", in: Bundle.main, compatibleWith: nil)!
    public static var simpleFeedColor: UIColor = UIColor(named: "simpleFeedColor", in: Bundle.main, compatibleWith: nil)!

    public static var tagColor: UIColor = UIColor(named: "tagColor", in: Bundle.main, compatibleWith: nil)!

    public static var readColor: UIColor = UIColor(named: "readColor", in: Bundle.main, compatibleWith: nil)!

    public static var borderColor: UIColor = UIColor(named: "borderColor", in: Bundle.main, compatibleWith: nil)!
}

public protocol FHGradedColor {
    var primary: UIColor { get }
    var secondary: UIColor { get }
    var tertiary: UIColor { get }
    var quaternary: UIColor { get }
}

public class FHLabelColors: FHGradedColor {
    public var primary: UIColor = UIColor(named: "labelPrimary", in: Bundle.main, compatibleWith: nil)!
    public var secondary: UIColor = UIColor(named: "labelSecondary", in: Bundle.main, compatibleWith: nil)!
    public var tertiary: UIColor = UIColor(named: "labelTertiary", in: Bundle.main, compatibleWith: nil)!
    public var quaternary: UIColor = UIColor(named: "labelQuaternary", in: Bundle.main, compatibleWith: nil)!
}

public class FHBackgroundColors: FHGradedColor {
    public var primary: UIColor = UIColor(named: "backgroundPrimary", in: Bundle.main, compatibleWith: nil)!
    public var secondary: UIColor = UIColor(named: "backgroundSecondary", in: Bundle.main, compatibleWith: nil)!
    public var tertiary: UIColor = UIColor(named: "backgroundTertiary", in: Bundle.main, compatibleWith: nil)!
    public var quaternary: UIColor = UIColor.red
}

public class FHBackgroundGroupedColors: FHGradedColor {
    public var primary: UIColor = UIColor(named: "backgroundPrimaryGrouped", in: Bundle.main, compatibleWith: nil)!
    public var secondary: UIColor = UIColor(named: "backgroundSecondaryGrouped", in: Bundle.main, compatibleWith: nil)!
    public var tertiary: UIColor = UIColor(named: "backgroundTertiaryGrouped", in: Bundle.main, compatibleWith: nil)!
    public var quaternary: UIColor = UIColor.red
}
