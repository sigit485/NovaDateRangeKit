import Foundation

struct CalendarDay: Hashable {
    let id: Int
    let date: Date?
    let dayText: String?
}

final class CalendarViewModel {

    // MARK: - Types

    enum SelectionOutcome {
        case none
        case didSelectStart(Date)
        case didSelectRange(DateRange)
        case didReset
    }

    // MARK: - Properties

    private let calendar: Calendar
    private let today: Date
    private let titleFormatter: DateFormatter

    private(set) var displayedMonth: Date
    private(set) var startDate: Date?
    private(set) var endDate: Date?
    var minDate: Date?

    // MARK: - Init

    init(calendar: Calendar = .current,
         currentDate: Date = Date(),
         minDate: Date? = nil) {
        self.calendar = calendar
        self.today = calendar.startOfDay(for: currentDate)
        self.displayedMonth = CalendarViewModel.startOfMonth(for: currentDate, calendar: calendar)
        self.minDate = minDate.map { calendar.startOfDay(for: $0) }

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale.current
        formatter.dateFormat = "LLLL yyyy"
        self.titleFormatter = formatter
    }

    // MARK: - Month

    func monthTitle() -> String {
        return titleFormatter.string(from: displayedMonth)
    }

    func displayedMonthIdentifier() -> Int {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        let year = components.year ?? 0
        let month = components.month ?? 0
        return (year * 100) + month
    }

    func moveMonth(by value: Int) {
        guard let nextMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) else {
            return
        }
        displayedMonth = CalendarViewModel.startOfMonth(for: nextMonth, calendar: calendar)
    }

    func makeDaysForDisplayedMonth() -> [CalendarDay] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let mondayFirstOffset = (firstWeekday + 5) % 7

        var days: [CalendarDay] = []
        var id = 0

        if mondayFirstOffset > 0 {
            for _ in 0..<mondayFirstOffset {
                days.append(CalendarDay(id: id, date: nil, dayText: nil))
                id += 1
            }
        }

        let monthComponents = calendar.dateComponents([.year, .month], from: firstOfMonth)

        for dayValue in monthRange {
            var components = monthComponents
            components.day = dayValue
            guard let date = calendar.date(from: components) else {
                continue
            }
            let normalizedDate = normalize(date)
            days.append(CalendarDay(id: id,
                                    date: normalizedDate,
                                    dayText: String(dayValue)))
            id += 1
        }

        let trailingCount = (7 - (days.count % 7)) % 7
        if trailingCount > 0 {
            for _ in 0..<trailingCount {
                days.append(CalendarDay(id: id, date: nil, dayText: nil))
                id += 1
            }
        }

        return days
    }

    // MARK: - Selection

    func select(date: Date) -> SelectionOutcome {
        let candidate = normalize(date)
        guard isSelectable(candidate) else {
            return .none
        }

        switch (startDate, endDate) {
        case (nil, _):
            startDate = candidate
            endDate = nil
            return .didSelectStart(candidate)

        case let (start?, nil):
            if calendar.isDate(start, inSameDayAs: candidate) {
                startDate = nil
                endDate = nil
                return .didReset
            }

            if candidate < start {
                startDate = candidate
                endDate = start
            } else {
                startDate = start
                endDate = candidate
            }

            if let range = selectedRange() {
                return .didSelectRange(range)
            }
            return .none

        case let (start?, end?):
            let isInsideCurrentSelection = isDateWithinSelection(candidate)
            if isInsideCurrentSelection || calendar.isDate(start, inSameDayAs: candidate) || calendar.isDate(end, inSameDayAs: candidate) {
                startDate = nil
                endDate = nil
                return .didReset
            }

            startDate = candidate
            endDate = nil
            return .didSelectStart(candidate)
        }
    }

    func selectedRange() -> DateRange? {
        guard let startDate, let endDate else {
            return nil
        }
        return DateRange(startDate: startDate, endDate: endDate)
    }

    func isStartDate(_ date: Date) -> Bool {
        guard let startDate else {
            return false
        }
        return calendar.isDate(startDate, inSameDayAs: normalize(date))
    }

    func isEndDate(_ date: Date) -> Bool {
        guard let endDate else {
            return false
        }
        return calendar.isDate(endDate, inSameDayAs: normalize(date))
    }

    func isToday(_ date: Date) -> Bool {
        return calendar.isDate(today, inSameDayAs: normalize(date))
    }

    func isInRange(_ date: Date) -> Bool {
        guard let startDate, let endDate else {
            return false
        }

        let value = normalize(date)
        return value > startDate && value < endDate
    }

    func isDateWithinSelection(_ date: Date) -> Bool {
        let value = normalize(date)

        if let startDate, let endDate {
            return value >= startDate && value <= endDate
        }

        if let startDate {
            return calendar.isDate(startDate, inSameDayAs: value)
        }

        return false
    }

    func selectionDates() -> Set<Date> {
        guard let startDate else {
            return []
        }

        guard let endDate else {
            return [startDate]
        }

        var dates: Set<Date> = [startDate, endDate]

        var cursor = startDate
        while cursor < endDate {
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: cursor) else {
                break
            }
            cursor = normalize(nextDay)
            if cursor < endDate {
                dates.insert(cursor)
            }
        }

        return dates
    }

    // MARK: - Validation

    func isSelectable(_ date: Date) -> Bool {
        guard let minDate else {
            return true
        }
        return normalize(date) >= minDate
    }

    // MARK: - Helpers

    func normalize(_ date: Date) -> Date {
        return calendar.startOfDay(for: date)
    }

    private static func startOfMonth(for date: Date, calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? calendar.startOfDay(for: date)
    }
}
