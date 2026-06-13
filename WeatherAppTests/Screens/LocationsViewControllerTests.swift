import XCTest
import WeatherCore
@testable import WeatherApp

@MainActor
final class LocationsViewControllerTests: XCTestCase {
    func test_didSelectRow_notifiesDelegate() {
        let viewModel = LocationsViewModel(store: MockSavedLocationsStore())
        viewModel.load()
        let sut = LocationsViewController(viewModel: viewModel)
        let delegate = MockLocationsViewControllerDelegate()
        sut.delegate = delegate
        sut.loadViewIfNeeded()

        sut.tableView(UITableView(), didSelectRowAt: IndexPath(row: 0, section: 0))

        XCTAssertEqual(delegate.didSelectSelections.count, 1)
    }

    func test_addButton_notifiesDelegate() throws {
        let sut = LocationsViewController(viewModel: LocationsViewModel(store: MockSavedLocationsStore()))
        let delegate = MockLocationsViewControllerDelegate()
        sut.delegate = delegate
        sut.loadViewIfNeeded()

        let addButton = try XCTUnwrap(sut.navigationItem.rightBarButtonItem)
        let target = try XCTUnwrap(addButton.target as? NSObject)
        let action = try XCTUnwrap(addButton.action)
        _ = target.perform(action)

        XCTAssertEqual(delegate.didTapAddCount, 1)
    }
}
