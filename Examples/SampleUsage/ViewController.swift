import UIKit

final class ViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let labelFontSize: CGFloat = 15
        static let sidePadding: CGFloat = 20
        static let calendarSidePadding: CGFloat = 12
        static let topPadding: CGFloat = 20
        static let verticalSpacing: CGFloat = 14
        static let calendarHeightRatio: CGFloat = 1.08
    }

    // MARK: - Views

    private let selectedRangeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.labelFontSize, weight: .medium)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Select a date range"
        return label
    }()

    private let calendarView: CalendarView = {
        let view = CalendarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale.current
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    // MARK: - Setup

    private func setupView() {
        view.backgroundColor = .white

        view.addSubview(selectedRangeLabel)
        view.addSubview(calendarView)

        calendarView.delegate = self
        calendarView.minDate = Calendar.current.startOfDay(for: Date())

        NSLayoutConstraint.activate([
            selectedRangeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.topPadding),
            selectedRangeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.sidePadding),
            selectedRangeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.sidePadding),

            calendarView.topAnchor.constraint(equalTo: selectedRangeLabel.bottomAnchor, constant: Constants.verticalSpacing),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.calendarSidePadding),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.calendarSidePadding),
            calendarView.heightAnchor.constraint(equalTo: calendarView.widthAnchor, multiplier: Constants.calendarHeightRatio)
        ])
    }
}

// MARK: - CalendarPickerDelegate

extension ViewController: CalendarPickerDelegate {
    func calendarPicker(_ picker: CalendarView, didSelectRange range: DateRange) {
        let start = dateFormatter.string(from: range.startDate)
        let end = dateFormatter.string(from: range.endDate)
        selectedRangeLabel.text = "Range: \(start) - \(end)"
    }

    func calendarPicker(_ picker: CalendarView, didSelectStartDate date: Date) {
        let start = dateFormatter.string(from: date)
        selectedRangeLabel.text = "Start date: \(start)"
    }
}
