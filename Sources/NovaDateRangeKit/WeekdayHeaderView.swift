import UIKit

final class WeekdayHeaderView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let weekdays = ["M", "T", "W", "T", "F", "S", "S"]
        static let fontSize: CGFloat = 13
    }

    // MARK: - Views

    private var weekdayLabels: [UILabel] = []

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        return nil
    }

    // MARK: - Setup

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill

        for symbol in Constants.weekdays {
            let label = UILabel()
            label.text = symbol
            label.textAlignment = .center
            label.font = .systemFont(ofSize: Constants.fontSize, weight: .semibold)
            label.textColor = .calendarSecondaryText
            weekdayLabels.append(label)
            stackView.addArrangedSubview(label)
        }

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Public

    func setWeekdayFont(_ font: UIFont) {
        weekdayLabels.forEach { $0.font = font }
    }
}
