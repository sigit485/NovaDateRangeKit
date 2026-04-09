import UIKit

final class CalendarHeaderView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let horizontalPadding: CGFloat = 12
        static let buttonSize: CGFloat = 32
        static let titleFontSize: CGFloat = 20
        static let iconInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    }

    // MARK: - Callbacks

    var onPreviousTapped: (() -> Void)?
    var onNextTapped: (() -> Void)?

    // MARK: - Views

    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .calendarPrimaryText
        button.accessibilityLabel = "Previous Month"
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
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

    func setTitleFont(_ font: UIFont) {
        titleLabel.font = font
    }

    // MARK: - Setup

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        configureNavigationButtons()

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

    private func configureNavigationButtons() {
        let backImage = CalendarHeaderView.loadBackIcon()?.withRenderingMode(.alwaysTemplate)
        previousButton.contentEdgeInsets = Constants.iconInsets
        nextButton.contentEdgeInsets = Constants.iconInsets

        if let backImage {
            previousButton.setImage(backImage, for: .normal)
            previousButton.setTitle(nil, for: .normal)

            nextButton.setImage(backImage, for: .normal)
            nextButton.setTitle(nil, for: .normal)
            nextButton.imageView?.transform = CGAffineTransform(scaleX: -1, y: 1)
            return
        }

        previousButton.setTitle("<", for: .normal)
        previousButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        nextButton.setTitle(">", for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
    }

    private static func loadBackIcon() -> UIImage? {
        let bundle = resourceBundle
        return UIImage(named: "icons8-back", in: bundle, compatibleWith: nil)
    }

    private static var resourceBundle: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        let classBundle = Bundle(for: CalendarHeaderView.self)
        if classBundle.path(forResource: "icons8-back", ofType: "png") != nil {
            return classBundle
        }
        if let bundleURL = classBundle.url(forResource: "NovaDateRangeKit", withExtension: "bundle"),
           let podBundle = Bundle(url: bundleURL) {
            return podBundle
        }
        if Bundle.main.path(forResource: "icons8-back", ofType: "png") != nil {
            return Bundle.main
        }
        if let bundleURL = Bundle.main.url(forResource: "NovaDateRangeKit", withExtension: "bundle"),
           let podBundle = Bundle(url: bundleURL) {
            return podBundle
        }
        return classBundle
        #endif
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
