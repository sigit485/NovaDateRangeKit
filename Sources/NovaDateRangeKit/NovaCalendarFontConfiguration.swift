import UIKit

public struct NovaCalendarFontConfiguration {

    // MARK: - Public Properties

    public var monthTitleFont: UIFont
    public var weekdayFont: UIFont
    public var dayFont: UIFont
    public var selectedDayFont: UIFont
    public var inRangeDayFont: UIFont
    public var todayDayFont: UIFont
    public var disabledDayFont: UIFont

    // MARK: - Init

    public init(monthTitleFont: UIFont = .systemFont(ofSize: 20, weight: .semibold),
                weekdayFont: UIFont = .systemFont(ofSize: 13, weight: .semibold),
                dayFont: UIFont = .systemFont(ofSize: 16, weight: .regular),
                selectedDayFont: UIFont = .systemFont(ofSize: 16, weight: .bold),
                inRangeDayFont: UIFont = .systemFont(ofSize: 16, weight: .bold),
                todayDayFont: UIFont = .systemFont(ofSize: 16, weight: .semibold),
                disabledDayFont: UIFont = .systemFont(ofSize: 16, weight: .regular)) {
        self.monthTitleFont = monthTitleFont
        self.weekdayFont = weekdayFont
        self.dayFont = dayFont
        self.selectedDayFont = selectedDayFont
        self.inRangeDayFont = inRangeDayFont
        self.todayDayFont = todayDayFont
        self.disabledDayFont = disabledDayFont
    }

    // MARK: - Defaults

    public static let `default` = NovaCalendarFontConfiguration()
}
