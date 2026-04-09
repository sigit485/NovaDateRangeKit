import UIKit

public final class CalendarPickerViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let topPadding: CGFloat = 12
        static let heightRatio: CGFloat = 1.05
    }

    // MARK: - Public

    public weak var delegate: CalendarPickerDelegate? {
        didSet {
            calendarView.delegate = delegate
        }
    }

    public var minDate: Date? {
        didSet {
            calendarView.minDate = minDate
        }
    }

    // MARK: - Views

    private let calendarView = CalendarView()

    // MARK: - Lifecycle

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    // MARK: - Setup

    private func setupView() {
        view.backgroundColor = .white
        calendarView.delegate = delegate
        calendarView.minDate = minDate ?? Calendar.current.startOfDay(for: Date())

        view.addSubview(calendarView)
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.topPadding),
            calendarView.heightAnchor.constraint(equalTo: calendarView.widthAnchor, multiplier: Constants.heightRatio)
        ])
    }
}
