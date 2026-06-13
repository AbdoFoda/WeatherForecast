import UIKit

@objc(SceneDelegate)
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var coordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        let coordinator = Self.makeCoordinator()
        coordinator.start(window: window)

        self.window = window
        self.coordinator = coordinator
    }

    private static func makeCoordinator() -> AppCoordinator {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains(UITestLaunchArgument.enabled) {
            return AppCoordinator.uiTesting()
        }
        #endif
        return AppCoordinator.live()
    }
}
