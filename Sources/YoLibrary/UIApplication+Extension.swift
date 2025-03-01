import UIKit

public extension UIApplication {
    /// **現在表示中の ViewController を取得**
    var topViewController: UIViewController? {
        guard let window = connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return nil }
        return window.rootViewController?.getTopViewController()
    }
}

private extension UIViewController {
    /// **最前面の ViewController を再帰的に取得**
    func getTopViewController() -> UIViewController {
        if let presentedViewController = presentedViewController {
            return presentedViewController.getTopViewController()
        } else if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.getTopViewController() ?? navigationController
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.getTopViewController() ?? tabBarController
        }
        return self
    }
}
