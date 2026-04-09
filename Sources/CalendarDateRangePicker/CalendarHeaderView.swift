import UIKit

final class CalendarHeaderView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let horizontalPadding: CGFloat = 12
        static let buttonSize: CGFloat = 32
        static let titleFontSize: CGFloat = 20
    }

    // MARK: - Callbacks

    var onPreviousTapped: (() -> Void)?
    var onNextTapped: (() -> Void)?

    // MARK: - Views

    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("<", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.tintColor = .calendarPrimaryText
        button.accessibilityLabel = "Previous Month"
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(">", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.tintColor = .calendarPrimaryText
        button.accessibilityLabel = "Next Month"
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.titleFontSize, weight: .semibold)
        label.textColor = .calendarPrimaryText
        label.textAlignment = .center
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        return nil
    }

    // MARK: - Public

    func update(title: String) {
        titleLabel.text = title
    }

    // MARK: - Setup

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        [previousButton, titleLabel, nextButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        previousButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            previousButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            previousButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            previousButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            previousButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),

            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            nextButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            nextButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: previousButton.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: nextButton.leadingAnchor, constant: -8)
        ])
    }

    // MARK: - Actions

    @objc
    private func previousTapped() {
        onPreviousTapped?()
    }

    @objc
    private func nextTapped() {
        onNextTapped?()
    }
}
