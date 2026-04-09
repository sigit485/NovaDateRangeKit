import UIKit

enum DayState {
    case normal
    case selected(isStart: Bool)
    case inRange(isStart: Bool, isEnd: Bool)
    case today
    case disabled
    case empty
}

final class CalendarDayCell: UICollectionViewCell {

    // MARK: - Constants

    private enum Constants {
        static let labelFontSize: CGFloat = 16
        static let horizontalInset: CGFloat = 1
        static let verticalInset: CGFloat = 4
        static let rangeHorizontalInset: CGFloat = 0
        static let minimumCircleInset: CGFloat = 6
        static let circleInsetRatio: CGFloat = 0.16
        static let rangeHeightRatio: CGFloat = 1.0
        static let connectedRangeOverlap: CGFloat = 2
        static let boundaryConnectorUnderlap: CGFloat = 8
        static let outlineLineWidth: CGFloat = 1
        static let badgeDiameterRatio: CGFloat = 0.34
        static let badgeMinimumDiameter: CGFloat = 7
        static let badgeMaximumDiameter: CGFloat = 8.5
        static let badgeHorizontalInset: CGFloat = 1
        static let badgeVerticalInset: CGFloat = 0.5
        static let badgeStrokeWidth: CGFloat = 1
    }

    static let reuseIdentifier = "CalendarDayCell"

    // MARK: - Fonts

    struct FontConfiguration {
        let normal: UIFont
        let selected: UIFont
        let inRange: UIFont
        let today: UIFont
        let disabled: UIFont

        static let `default` = FontConfiguration(
            normal: .systemFont(ofSize: Constants.labelFontSize, weight: .regular),
            selected: .systemFont(ofSize: Constants.labelFontSize, weight: .bold),
            inRange: .systemFont(ofSize: Constants.labelFontSize, weight: .bold),
            today: .systemFont(ofSize: Constants.labelFontSize, weight: .semibold),
            disabled: .systemFont(ofSize: Constants.labelFontSize, weight: .regular)
        )
    }

    // MARK: - Views

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: Constants.labelFontSize, weight: .regular)
        return label
    }()

    private let rangeLayer = CAShapeLayer()
    private let selectionCircleLayer = CAShapeLayer()
    private let todayBadgeLayer = CAShapeLayer()

    // MARK: - State

    private var dayState: DayState = .empty
    private var dayText: String?
    private var connectsLeft = false
    private var connectsRight = false
    private var fontConfiguration = FontConfiguration.default

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
        return nil
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        dayState = .empty
        dayText = nil
        connectsLeft = false
        connectsRight = false
        isUserInteractionEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyStateLayout()
    }

    // MARK: - Public

    func configure(dayText: String?,
                   state: DayState,
                   connectsLeft: Bool,
                   connectsRight: Bool) {
        self.dayText = dayText
        self.dayState = state
        self.connectsLeft = connectsLeft
        self.connectsRight = connectsRight
        setNeedsLayout()
    }

    func setFonts(_ fontConfiguration: FontConfiguration) {
        self.fontConfiguration = fontConfiguration
        setNeedsLayout()
    }

    // MARK: - Setup

    private func setupCell() {
        contentView.clipsToBounds = false
        clipsToBounds = false

        rangeLayer.fillColor = UIColor.clear.cgColor
        rangeLayer.contentsScale = UIScreen.main.scale
        rangeLayer.allowsEdgeAntialiasing = false
        selectionCircleLayer.fillColor = UIColor.clear.cgColor
        selectionCircleLayer.contentsScale = UIScreen.main.scale
        todayBadgeLayer.fillColor = UIColor.clear.cgColor
        todayBadgeLayer.strokeColor = UIColor.clear.cgColor
        todayBadgeLayer.lineWidth = Constants.badgeStrokeWidth
        todayBadgeLayer.lineJoin = .round
        todayBadgeLayer.lineCap = .round
        todayBadgeLayer.contentsScale = UIScreen.main.scale

        // Range highlight should stay behind selected circles.
        contentView.layer.addSublayer(rangeLayer)
        contentView.layer.addSublayer(selectionCircleLayer)
        contentView.layer.addSublayer(todayBadgeLayer)
        contentView.addSubview(dayLabel)

        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    // MARK: - Drawing

    private func applyStateLayout() {
        let bounds = contentView.bounds
        guard bounds.width > 0, bounds.height > 0 else {
            return
        }

        dayLabel.text = dayText

        rangeLayer.path = nil
        rangeLayer.fillColor = UIColor.clear.cgColor
        selectionCircleLayer.path = nil
        selectionCircleLayer.fillColor = UIColor.clear.cgColor
        selectionCircleLayer.strokeColor = UIColor.clear.cgColor
        todayBadgeLayer.path = nil
        todayBadgeLayer.fillColor = UIColor.clear.cgColor
        todayBadgeLayer.strokeColor = UIColor.clear.cgColor

        let contentRect = bounds.insetBy(dx: Constants.horizontalInset, dy: Constants.verticalInset)
        let circleBase = min(contentRect.width, contentRect.height)
        let circleInset = max(Constants.minimumCircleInset,
                              floor(circleBase * Constants.circleInsetRatio))
        let circleSide = max(0, circleBase - (circleInset * 2))
        let circleRect = CGRect(x: contentRect.midX - (circleSide / 2),
                                y: contentRect.midY - (circleSide / 2),
                                width: circleSide,
                                height: circleSide)
        let pixelAlignedCircleRect = alignedToPixel(circleRect)
        let circleRadius = min(pixelAlignedCircleRect.width, pixelAlignedCircleRect.height) / 2
        let rangeHeight = pixelAlignedCircleRect.height * Constants.rangeHeightRatio
        // Keep range highlight flush to cell edges so adjacent in-range cells connect seamlessly.
        let baseRangeRect = CGRect(x: bounds.minX + Constants.rangeHorizontalInset,
                                   y: contentRect.midY - (rangeHeight / 2),
                                   width: bounds.width - (Constants.rangeHorizontalInset * 2),
                                   height: rangeHeight)

        var connectedRangeRect = baseRangeRect
        if connectsLeft {
            connectedRangeRect.origin.x -= Constants.connectedRangeOverlap
            connectedRangeRect.size.width += Constants.connectedRangeOverlap
        }
        if connectsRight {
            connectedRangeRect.size.width += Constants.connectedRangeOverlap
        }
        let pixelAlignedRangeRect = alignedToPixel(connectedRangeRect)

        switch dayState {
        case .empty:
            dayLabel.text = nil
            isUserInteractionEnabled = false

        case .disabled:
            dayLabel.font = fontConfiguration.disabled
            dayLabel.textColor = .calendarDisabledText
            isUserInteractionEnabled = false

        case .normal:
            dayLabel.font = fontConfiguration.normal
            dayLabel.textColor = .calendarNormalDayText
            isUserInteractionEnabled = true

        case .today:
            dayLabel.font = fontConfiguration.today
            dayLabel.textColor = .calendarPrimaryText
            selectionCircleLayer.path = nil
            selectionCircleLayer.fillColor = UIColor.clear.cgColor
            selectionCircleLayer.strokeColor = UIColor.clear.cgColor
            todayBadgeLayer.path = makeTodayBadgePath(anchoredTo: pixelAlignedCircleRect).cgPath
            todayBadgeLayer.fillColor = UIColor.calendarTodayBlue.cgColor
            todayBadgeLayer.strokeColor = UIColor.clear.cgColor
            isUserInteractionEnabled = true

        case let .selected(isStart):
            dayLabel.font = fontConfiguration.selected
            dayLabel.textColor = .white
            selectionCircleLayer.path = UIBezierPath(ovalIn: pixelAlignedCircleRect).cgPath
            selectionCircleLayer.fillColor = UIColor.calendarOrange.cgColor

            // When range spans beyond the selected boundary date, draw half-pill to connect rows.
            if isStart, connectsRight {
                let connectorStartX = pixelAlignedCircleRect.maxX - Constants.boundaryConnectorUnderlap
                let halfRect = CGRect(x: connectorStartX,
                                      y: baseRangeRect.minY,
                                      width: max(0, baseRangeRect.maxX - connectorStartX),
                                      height: baseRangeRect.height)
                // Keep connector edge straight so selected boundary doesn't show a rounded nub.
                rangeLayer.path = UIBezierPath(rect: alignedToPixel(halfRect)).cgPath
                rangeLayer.fillColor = UIColor.calendarRangeBackground.cgColor
            } else if !isStart, connectsLeft {
                let connectorEndX = pixelAlignedCircleRect.minX + Constants.boundaryConnectorUnderlap
                let halfRect = CGRect(x: baseRangeRect.minX,
                                      y: baseRangeRect.minY,
                                      width: max(0, connectorEndX - baseRangeRect.minX),
                                      height: baseRangeRect.height)
                // Keep connector edge straight so selected boundary doesn't show a rounded nub.
                rangeLayer.path = UIBezierPath(rect: alignedToPixel(halfRect)).cgPath
                rangeLayer.fillColor = UIColor.calendarRangeBackground.cgColor
            }
            isUserInteractionEnabled = true

        case let .inRange(isStart, isEnd):
            dayLabel.font = fontConfiguration.inRange
            dayLabel.textColor = .calendarOrange
            rangeLayer.path = makeRangePath(rect: pixelAlignedRangeRect, isStart: isStart, isEnd: isEnd).cgPath
            rangeLayer.fillColor = UIColor.calendarRangeBackground.cgColor
            isUserInteractionEnabled = true
        }

        contentView.layer.cornerRadius = circleRadius
    }

    private func makeRangePath(rect: CGRect, isStart: Bool, isEnd: Bool) -> UIBezierPath {
        let cornerRadius = rect.height / 2

        if isStart && isEnd {
            return UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        }

        if isStart {
            return UIBezierPath(roundedRect: rect,
                                byRoundingCorners: [.topLeft, .bottomLeft],
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        }

        if isEnd {
            return UIBezierPath(roundedRect: rect,
                                byRoundingCorners: [.topRight, .bottomRight],
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        }

        return UIBezierPath(rect: rect)
    }

    private func makeTodayBadgePath(anchoredTo circleRect: CGRect) -> UIBezierPath {
        let unclampedDiameter = circleRect.width * Constants.badgeDiameterRatio
        let diameter = min(Constants.badgeMaximumDiameter,
                           max(Constants.badgeMinimumDiameter, unclampedDiameter))
        let badgeRect = alignedToPixel(CGRect(x: circleRect.maxX - diameter - Constants.badgeHorizontalInset,
                                              y: circleRect.minY + Constants.badgeVerticalInset,
                                              width: diameter,
                                              height: diameter))
        return UIBezierPath(ovalIn: badgeRect)
    }

    private func alignedToPixel(_ rect: CGRect) -> CGRect {
        let scale = UIScreen.main.scale
        let minX = floor(rect.minX * scale) / scale
        let minY = floor(rect.minY * scale) / scale
        let maxX = ceil(rect.maxX * scale) / scale
        let maxY = ceil(rect.maxY * scale) / scale
        return CGRect(x: minX,
                      y: minY,
                      width: max(0, maxX - minX),
                      height: max(0, maxY - minY))
    }
}
