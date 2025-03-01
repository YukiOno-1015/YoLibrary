import UIKit

/// **すべての TabBarController のベースとなるクラス**
open class BaseTabBarController: UITabBarController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
    }

    open func setupTabBarAppearance() {
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .systemBackground
    }
}
