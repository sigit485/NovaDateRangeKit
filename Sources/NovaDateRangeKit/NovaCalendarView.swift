import UIKit

public protocol CalendarPickerDelegate: AnyObject {
    func calendarPicker(_ picker: NovaCalendarView, didSelectRange range: DateRange)
    func calendarPicker(_ picker: NovaCalendarView, didSelectStartDate date: Date)
}

public final class NovaCalendarView: UIView {

    // MARK: - Constants

    private enum Constants {
        static let headerHeight: CGFloat = 56
        static let weekdayHeight: CGFloat = 24
        static let horizontalPadding: CGFloat = 16
        static let verticalSpacing: CGFloat = 10
        static let gridTopSpacing: CGFloat = 6
        static let monthSlideOffset: CGFloat = 26
        static let monthTransitionDuration: TimeInterval = 0.16
    }

    private enum Section {
        case main
    }

    private struct DayItem: Hashable {
        let id: Int
    }

    // MARK: - Public

    public weak var delegate: CalendarPickerDelegate?

    public var minDate: Date? {
        didSet {
            viewModel.minDate = minDate.map { viewModel.normalize($0) }
            reloadMonth()
        }
    }

    // MARK: - Views

    private let headerView = CalendarHeaderView()
    private let weekdayHeaderView = WeekdayHeaderView()
    private let calendarCollectionView = CalendarCollectionView()

    // MARK: - State

    private let viewModel: CalendarViewModel
    private var days: [CalendarDay] = []
    private var dayLookupByID: [Int: CalendarDay] = [:]
    private var modernDataSource: UICollectionViewDataSource?

    // MARK: - Init

    init(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        self.minDate = viewModel.minDate
        super.init(frame: .zero)
        setupView()
        setupActions()
        configureDataSource()
        reloadMonth()
    }

    public override init(frame: CGRect) {
        self.viewModel = CalendarViewModel()
        self.minDate = viewModel.minDate
        super.init(frame: frame)
        setupView()
        setupActions()
        configureDataSource()
        reloadMonth()
    }

    public convenience init() {
        self.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    // MARK: - Setup

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white

        addSubview(headerView)
        addSubview(weekdayHeaderView)
        addSubview(calendarCollectionView)

        calendarCollectionView.register(CalendarDayCell.self,
                                        forCellWithReuseIdentifier: CalendarDayCell.reuseIdentifier)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            headerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            headerView.heightAnchor.constraint(equalToConstant: Constants.headerHeight),

            weekdayHeaderView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Constants.verticalSpacing),
            weekdayHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            weekdayHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            weekdayHeaderView.heightAnchor.constraint(equalToConstant: Constants.weekdayHeight),

            calendarCollectionView.topAnchor.constraint(equalTo: weekdayHeaderView.bottomAnchor, constant: Constants.gridTopSpacing),
            calendarCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            calendarCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),
            calendarCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupActions() {
        headerView.onPreviousTapped = { [weak self] in
            self?.changeMonth(by: -1)
        }

        headerView.onNextTapped = { [weak self] in
            self?.changeMonth(by: 1)
        }

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        calendarCollectionView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        calendarCollectionView.addGestureRecognizer(swipeRight)
    }

    private func configureDataSource() {
        calendarCollectionView.delegate = self

        if #available(iOS 13.0, *) {
            configureDiffableDataSource()
        } else {
            calendarCollectionView.dataSource = self
        }
    }

    @available(iOS 13.0, *)
    private func configureDiffableDataSource() {
        let dataSource = UICollectionViewDiffableDataSource<Section, DayItem>(
            collectionView: calendarCollectionView
        ) { [weak self] collectionView, indexPath, item in
            guard let self else {
                return nil
            }

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CalendarDayCell.reuseIdentifier,
                for: indexPath
            ) as? CalendarDayCell else {
                return UICollectionViewCell()
            }

            guard let day = self.dayLookupByID[item.id] else {
                return cell
            }

            self.configure(cell: cell, for: day, at: indexPath.item)
            return cell
        }

        modernDataSource = dataSource
    }

    // MARK: - Rendering

    private func reloadMonth() {
        headerView.update(title: viewModel.monthTitle())
        days = viewModel.makeDaysForDisplayedMonth()
        dayLookupByID = Dictionary(uniqueKeysWithValues: days.map { ($0.id, $0) })

        if #available(iOS 13.0, *),
           let diffableDataSource = modernDataSource as? UICollectionViewDiffableDataSource<Section, DayItem> {
            var snapshot = NSDiffableDataSourceSnapshot<Section, DayItem>()
            snapshot.appendSections([.main])
            snapshot.appendItems(days.map { DayItem(id: $0.id) }, toSection: .main)
            diffableDataSource.apply(snapshot, animatingDifferences: false)
        } else {
            calendarCollectionView.reloadData()
        }
    }

    private func configure(cell: CalendarDayCell, for day: CalendarDay, at index: Int) {
        guard let date = day.date else {
            cell.configure(dayText: nil,
                           state: .empty,
                           connectsLeft: false,
                           connectsRight: false)
            return
        }

        let state = resolveState(for: date, at: index)

        let leftConnected = index % 7 != 0 && isSelectionConnected(at: index - 1)
        let rightConnected = index % 7 != 6 && isSelectionConnected(at: index + 1)

        cell.configure(dayText: day.dayText,
                       state: state,
                       connectsLeft: leftConnected,
                       connectsRight: rightConnected)
    }

    private func resolveState(for date: Date, at index: Int) -> DayState {
        if !viewModel.isSelectable(date) {
            return .disabled
        }

        let isStart = viewModel.isStartDate(date)
        let isEnd = viewModel.isEndDate(date)

        if isStart {
            return .selected(isStart: true)
        }

        if isEnd {
            return .selected(isStart: false)
        }

        if viewModel.isInRange(date) {
            let startCap = !(index % 7 != 0 && isSelectionConnected(at: index - 1))
            let endCap = !(index % 7 != 6 && isSelectionConnected(at: index + 1))
            return .inRange(isStart: startCap, isEnd: endCap)
        }

        if viewModel.isToday(date) {
            return .today
        }

        return .normal
    }

    private func isSelectionConnected(at index: Int) -> Bool {
        guard days.indices.contains(index), let date = days[index].date else {
            return false
        }
        return viewModel.isDateWithinSelection(date)
    }

    private func reloadSelectionDiff(oldDates: Set<Date>, newDates: Set<Date>) {
        var affectedDates = oldDates.union(newDates)

        let datePool = oldDates.union(newDates)
        for date in datePool {
            if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: date) {
                affectedDates.insert(viewModel.normalize(previousDay))
            }
            if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: date) {
                affectedDates.insert(viewModel.normalize(nextDay))
            }
        }

        let indexPaths = days.enumerated().compactMap { index, day -> IndexPath? in
            guard let date = day.date else {
                return nil
            }
            if affectedDates.contains(date) {
                return IndexPath(item: index, section: 0)
            }
            return nil
        }

        guard !indexPaths.isEmpty else {
            return
        }

        calendarCollectionView.reloadItems(at: indexPaths)
    }

    // MARK: - Month Navigation

    private func changeMonth(by value: Int) {
        let directionOffset = value > 0 ? -Constants.monthSlideOffset : Constants.monthSlideOffset

        UIView.transition(with: calendarCollectionView,
                          duration: Constants.monthTransitionDuration,
                          options: [.curveEaseInOut, .beginFromCurrentState],
                          animations: {
            self.calendarCollectionView.transform = CGAffineTransform(translationX: directionOffset, y: 0)
            self.calendarCollectionView.alpha = 0
        }, completion: { [weak self] _ in
            guard let self else {
                return
            }

            self.viewModel.moveMonth(by: value)
            self.reloadMonth()

            self.calendarCollectionView.transform = CGAffineTransform(translationX: -directionOffset, y: 0)
            UIView.transition(with: self.calendarCollectionView,
                              duration: Constants.monthTransitionDuration,
                              options: [.curveEaseInOut, .beginFromCurrentState],
                              animations: {
                self.calendarCollectionView.transform = .identity
                self.calendarCollectionView.alpha = 1
            })
        })
    }

    // MARK: - Actions

    @objc
    private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            changeMonth(by: 1)
        case .right:
            changeMonth(by: -1)
        default:
            break
        }
    }
}

// MARK: - UICollectionViewDataSource (iOS 12 fallback)

extension NovaCalendarView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }

    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CalendarDayCell.reuseIdentifier,
            for: indexPath
        ) as? CalendarDayCell else {
            return UICollectionViewCell()
        }

        let day = days[indexPath.item]
        configure(cell: cell, for: day, at: indexPath.item)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension NovaCalendarView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard days.indices.contains(indexPath.item),
              let date = days[indexPath.item].date else {
            return
        }

        guard viewModel.isSelectable(date) else {
            return
        }

        let oldDates = viewModel.selectionDates()
        let outcome = viewModel.select(date: date)
        let newDates = viewModel.selectionDates()

        switch outcome {
        case let .didSelectStart(startDate):
            delegate?.calendarPicker(self, didSelectStartDate: startDate)
            reloadSelectionDiff(oldDates: oldDates, newDates: newDates)

        case let .didSelectRange(range):
            delegate?.calendarPicker(self, didSelectRange: range)
            reloadSelectionDiff(oldDates: oldDates, newDates: newDates)

        case .didReset:
            reloadSelectionDiff(oldDates: oldDates, newDates: newDates)

        case .none:
            break
        }
    }
}

@available(*, deprecated, renamed: "NovaCalendarView")
public typealias CalendarView = NovaCalendarView
