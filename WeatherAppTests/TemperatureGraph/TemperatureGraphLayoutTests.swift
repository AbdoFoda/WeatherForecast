import XCTest
@testable import WeatherApp

@MainActor
final class TemperatureGraphLayoutTests: XCTestCase {
    private var dataSource: MockCollectionViewDataSource!

    override func setUp() {
        super.setUp()
        dataSource = MockCollectionViewDataSource(itemCount: 4)
    }

    func test_prepare_setsContentSizeFromItemCount() {
        let layout = TemperatureGraphLayout()
        layout.itemWidth = 88
        layout.cellContentHeight = 160
        layout.headerBandHeight = 36

        let collectionView = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: 320, height: 200),
            collectionViewLayout: layout
        )
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = dataSource

        layout.prepare()

        XCTAssertEqual(layout.collectionViewContentSize.width, 352)
        XCTAssertEqual(layout.collectionViewContentSize.height, 196)
    }

    func test_prepare_placesCellsBelowHeaderBand() {
        let layout = TemperatureGraphLayout()
        let collectionView = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: 320, height: 200),
            collectionViewLayout: layout
        )
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        dataSource = MockCollectionViewDataSource(itemCount: 2)
        collectionView.dataSource = dataSource

        layout.prepare()

        let first = layout.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertEqual(first?.frame.origin.y, layout.headerBandHeight)
        XCTAssertEqual(first?.frame.width, layout.itemWidth)
    }

    func test_stickyHeader_staysWithinNextHeaderBoundary() {
        let layout = TemperatureGraphLayout()
        layout.dayHeaders = [(itemIndex: 0, label: "Mon"), (itemIndex: 3, label: "Tue")]

        let collectionView = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: 320, height: 200),
            collectionViewLayout: layout
        )
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        dataSource = MockCollectionViewDataSource(itemCount: 5)
        collectionView.dataSource = dataSource
        collectionView.contentOffset = CGPoint(x: 200, y: 0)

        layout.prepare()

        let header = layout.layoutAttributesForSupplementaryView(
            ofKind: TemperatureGraphLayout.dayHeaderKind,
            at: IndexPath(item: 0, section: 0)
        )

        XCTAssertLessThanOrEqual(header?.frame.maxX ?? 0, CGFloat(3) * layout.itemWidth)
    }
}
