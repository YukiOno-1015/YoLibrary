import UIKit

/// **すべての `UITabBarController` のベースとなるクラス**
open class BaseTabBarController: UITabBarController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBarAppearance()
    }

    /// **タブバーの外観を設定（オーバーライド可能）**
    open func setupTabBarAppearance() {
        Utils.setTabBarAppearance(self, backgroundColor: .systemBackground, tintColor: .systemBlue, isTranslucent: false)
    }
}
