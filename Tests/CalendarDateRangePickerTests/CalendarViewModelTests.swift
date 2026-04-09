import XCTest
@testable import CalendarDateRangePicker

final class CalendarViewModelTests: XCTestCase {

    func testSecondTapBeforeStartAutoSwapsRange() {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.year = 2026
        components.month = 4
        components.day = 15
        let baseDate = calendar.date(from: components) ?? Date()

        let viewModel = CalendarViewModel(calendar: calendar,
                                          currentDate: baseDate,
                                          minDate: nil)

        components.day = 10
        let firstTap = calendar.date(from: components) ?? baseDate
        _ = viewModel.select(date: firstTap)

        components.day = 5
        let secondTap = calendar.date(from: components) ?? baseDate
        _ = viewModel.select(date: secondTap)

        let range = viewModel.selectedRange()
        XCTAssertNotNil(range)
        XCTAssertEqual(range?.startDate, calendar.startOfDay(for: secondTap))
        XCTAssertEqual(range?.endDate, calendar.startOfDay(for: firstTap))
    }

    func testMinDateDisablesPastDates() {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.year = 2026
        components.month = 4
        components.day = 10
        let minDate = calendar.date(from: components) ?? Date()

        let viewModel = CalendarViewModel(calendar: calendar,
                                          currentDate: minDate,
                                          minDate: minDate)

        components.day = 9
        let pastDate = calendar.date(from: components) ?? minDate

        XCTAssertFalse(viewModel.isSelectable(pastDate))
    }
}
