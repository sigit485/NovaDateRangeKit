import UIKit

extension UIColor {
    static let calendarOrange = UIColor(red: 1.0,
                                        green: 0.6,
                                        blue: 0.2,
                                        alpha: 1.0)

    static let calendarRangeBackground = UIColor(red: 1.0,
                                                  green: 0.95,
                                                  blue: 0.88,
                                                  alpha: 1.0)

    static let calendarTodayBlue = UIColor.systemBlue

    static var calendarPrimaryText: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        }
        return .black
    }

    static var calendarSecondaryText: UIColor {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        }
        return .darkGray
    }

    static var calendarNormalDayText: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray
        }
        return UIColor(white: 0.45, alpha: 1.0)
    }

    static var calendarDisabledText: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray4
        }
        return UIColor(white: 0.78, alpha: 1.0)
    }

    static var calendarOutline: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray5
        }
        return UIColor(white: 0.86, alpha: 1.0)
    }
}
