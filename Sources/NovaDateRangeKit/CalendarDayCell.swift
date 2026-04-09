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
        static let minimumCircleInset: CGFloat = 6
        static let circleInsetRatio: CGFloat = 0.16
        static let rangeHeightRatio: CGFloat = 0.62
        static let outlineLineWidth: CGFloat = 1
        static let badgeRadiusRatio: CGFloat = 0.16
        static let badgeTipLeftXRatio: CGFloat = 0.45
        static let badgeTipLeftYRatio: CGFloat = 0.72
        static let badgeTipXRatio: CGFloat = 0.05
        static let badgeTipYRatio: CGFloat = 1.75
        static let badgeTipRightXRatio: CGFloat = 0.35
        static let badgeTipRightYRatio: CGFloat = 0.66
    }

    static let reuseIdentifier = "CalendarDayCell"

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

    // MARK: - Setup

    private func setupCell() {
        contentView.clipsToBounds = false
        clipsToBounds = false

        rangeLayer.fillColor = UIColor.clear.cgColor
        selectionCircleLayer.fillColor = UIColor.clear.cgColor
        todayBadgeLayer.fillColor = UIColor.clear.cgColor

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

        let contentRect = bounds.insetBy(dx: Constants.horizontalInset, dy: Constants.verticalInset)
        let circleInset = max(Constants.minimumCircleInset,
                              floor(contentRect.width * Constants.circleInsetRatio))
        let circleRect = contentRect.insetBy(dx: circleInset, dy: circleInset)
        let circleRadius = min(circleRect.width, circleRect.height) / 2
        let rangeHeight = circleRect.height * Constants.rangeHeightRatio
        let rangeRect = CGRect(x: contentRect.minX,
                               y: contentRect.midY - (rangeHeight / 2),
                               width: contentRect.width,
                               height: rangeHeight)

        switch dayState {
        case .empty:
            dayLabel.text = nil
            isUserInteractionEnabled = false

        case .disabled:
            dayLabel.font = .systemFont(ofSize: Constants.labelFontSize, weight: .regular)
            dayLabel.textColor = .calendarDisabledText
            isUserInteractionEnabled = false

        case .normal:
            dayLabel.font = .systemFont(ofSize: Constants.labelFontSize, weight: .regular)
            dayLabel.textColor = .calendarNormalDayText
            isUserInteractionEnabled = true

        case .today:
            dayLabel.font = .systemFont(ofSize: Constants.labelFontSize, weight: .semibold)
            dayLabel.textColor = .calendarPrimaryText
            selectionCircleLayer.path = UIBezierPath(ovalIn: circleRect).cgPath
            selectionCircleLayer.fillColor = UIColor.clear.cgColor
            selectionCircleLayer.strokeColor = UIColor.calendarOutline.cgColor
            selectionCircleLayer.lineWidth = Constants.outlineLineWidth
            todayBadgeLayer.path = makeTodayBadgePath(anchoredTo: circleRect).cgPath
            todayBadgeLayer.fillColor = UIColor.calendarTodayBlue.cgColor
            isUserInteractionEnabled = true

        case let .selected(isStart):
            dayLabel.font = .systemFont(ofSize: Constants.labelFontSize, weight: .bold)
            dayLabel.textColor = .white
            selectionCircleLayer.path = UIBezierPath(ovalIn: circleRect).cgPath
            selectionCircleLayer.fillColor = UIColor.calendarOrange.cgColor

            // When range spans beyond the selected boundary date, draw half-pill to connect rows.
            if isStart, connectsRight {
                let halfRect = CGRect(x: rangeRect.midX,
                                      y: rangeRect.minY,
                                      width: rangeRect.width / 2,
                                      height: rangeRect.height)
                let halfPath = UIBezierPath(roundedRect: halfRect,
                                            byRoundingCorners: [.topRight, .bottomRight],
                                            cornerRadii: CGSize(width: halfRect.height / 2,
                                                                height: halfRect.height / 2))
                rangeLayer.path = halfPath.cgPath
                rangeLayer.fillColor = UIColor.calendarRangeBackground.cgColor
            } else if !isStart, connectsLeft {
                let halfRect = CGRect(x: rangeRect.minX,
                                      y: rangeRect.minY,
                                      width: rangeRect.width / 2,
                                      height: rangeRect.height)
                let halfPath = UIBezierPath(roundedRect: halfRect,
                                            byRoundingCorners: [.topLeft, .bottomLeft],
                                            cornerRadii: CGSize(width: halfRect.height / 2,
                                                                height: halfRect.height / 2))
                rangeLayer.path = halfPath.cgPath
                rangeLayer.fillColor = UIColor.calendarRangeBackground.cgColor
            }
            isUserInteractionEnabled = true

        case let .inRange(isStart, isEnd):
            dayLabel.font = .systemFont(ofSize: Constants.labelFontSize, weight: .bold)
            dayLabel.textColor = .calendarOrange
            rangeLayer.path = makeRangePath(rect: rangeRect, isStart: isStart, isEnd: isEnd).cgPath
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
        let radius = circleRect.width * Constants.badgeRadiusRatio
        let center = CGPoint(x: circleRect.maxX - radius, y: circleRect.minY + radius)

        let bubblePath = UIBezierPath(arcCenter: center,
                                      radius: radius,
                                      startAngle: 0,
                                      endAngle: .pi * 2,
                                      clockwise: true)

        let tipLeft = CGPoint(x: center.x - radius * Constants.badgeTipLeftXRatio,
                              y: center.y + radius * Constants.badgeTipLeftYRatio)
        let tip = CGPoint(x: center.x - radius * Constants.badgeTipXRatio,
                          y: center.y + radius * Constants.badgeTipYRatio)
        let tipRight = CGPoint(x: center.x + radius * Constants.badgeTipRightXRatio,
                               y: center.y + radius * Constants.badgeTipRightYRatio)

        bubblePath.move(to: tipLeft)
        bubblePath.addLine(to: tip)
        bubblePath.addLine(to: tipRight)
        bubblePath.close()

        return bubblePath
    }
}
