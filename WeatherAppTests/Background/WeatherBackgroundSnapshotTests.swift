import XCTest
import WeatherCore
@testable import WeatherApp

@MainActor
final class WeatherBackgroundSnapshotTests: XCTestCase {
    func testSnapshot_catalog_iPhone() {
        JSONSnapshotTesting.assertSnapshot(
            WeatherBackgroundSnapshotFixtures.catalogSnapshot(for: .iPhone),
            named: "catalog"
        )
    }

    func testSnapshot_catalog_iPad() {
        JSONSnapshotTesting.assertSnapshot(
            WeatherBackgroundSnapshotFixtures.catalogSnapshot(for: .iPad),
            named: "catalog"
        )
    }

    func testSnapshot_allWeatherScenes_iPhone() {
        for scene in WeatherBackgroundSnapshotFixtures.previewScenes {
            let background = makeBackground(for: scene, variant: .iPhone)
            JSONSnapshotTesting.assertSnapshot(
                background.snapshotRepresentation(),
                named: scene.rawValue
            )
        }
    }

    func testSnapshot_allWeatherScenes_iPad() {
        for scene in WeatherBackgroundSnapshotFixtures.previewScenes {
            let background = makeBackground(for: scene, variant: .iPad)
            JSONSnapshotTesting.assertSnapshot(
                background.snapshotRepresentation(),
                named: scene.rawValue
            )
        }
    }

    private func makeBackground(
        for scene: WeatherScene,
        variant: WeatherBackgroundSnapshotFixtures.DeviceVariant
    ) -> WeatherBackgroundView {
        let view = WeatherBackgroundView(
            frame: CGRect(origin: .zero, size: variant.canvasSize)
        )
        view.configureForSnapshot(with: WeatherBackgroundSnapshotFixtures.configuration(for: scene))
        view.layoutIfNeeded()
        return view
    }
}
