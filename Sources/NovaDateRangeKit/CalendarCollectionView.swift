import UIKit

final class CalendarCollectionView: UICollectionView {

    // MARK: - Constants

    private enum Constants {
        static let columns: CGFloat = 7
    }

    // MARK: - Properties

    private let flowLayout = UICollectionViewFlowLayout()

    // MARK: - Init

    init() {
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        setupCollectionView()
    }

    required init?(coder: NSCoder) {
        return nil
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        let availableWidth = bounds.width
        guard availableWidth > 0 else {
            return
        }

        let side = floor(availableWidth / Constants.columns)
        let itemSize = CGSize(width: side, height: side)

        if flowLayout.itemSize != itemSize {
            flowLayout.itemSize = itemSize
            flowLayout.invalidateLayout()
        }
    }

    // MARK: - Setup

    private func setupCollectionView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        alwaysBounceVertical = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false

        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.sectionInset = .zero
    }
}
