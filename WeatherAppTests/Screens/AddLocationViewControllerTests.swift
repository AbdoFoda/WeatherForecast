import XCTest
import WeatherCore
@testable import WeatherApp

@MainActor
final class AddLocationViewControllerTests: XCTestCase {
    func test_cancelButton_notifiesDelegate() throws {
        let sut = AddLocationViewController(viewModel: MockAddLocationViewModel())
        let delegate = MockAddLocationViewControllerDelegate()
        sut.delegate = delegate
        sut.loadViewIfNeeded()

        let cancelButton = try XCTUnwrap(sut.navigationItem.leftBarButtonItem)
        let target = try XCTUnwrap(cancelButton.target as? NSObject)
        let action = try XCTUnwrap(cancelButton.action)
        _ = target.perform(action)

        XCTAssertEqual(delegate.didCancelCount, 1)
    }

    func test_didSelectResult_notifiesDelegate() {
        let paris = LocationModel(id: "paris", name: "Paris", lat: 48.85, lon: 2.35, country: "FR")
        let viewModel = MockAddLocationViewModel()
        viewModel.results = [paris]
        let sut = AddLocationViewController(viewModel: viewModel)
        let delegate = MockAddLocationViewControllerDelegate()
        sut.delegate = delegate
        sut.loadViewIfNeeded()

        sut.tableView(UITableView(), didSelectRowAt: IndexPath(row: 0, section: 0))

        XCTAssertEqual(delegate.didSelectLocations, [paris])
    }
}
