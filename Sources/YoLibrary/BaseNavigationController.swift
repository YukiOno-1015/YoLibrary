import UIKit

/// **すべての `UINavigationController` のベースとなるクラス**
open class BaseNavigationController: UINavigationController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarAppearance()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarAppearance()
    }

    /// **ナビゲーションバーの外観を設定（オーバーライド可能）**
    open func setupNavigationBarAppearance() {
        Utils.setNavigationBarAppearance(
            self,
            backgroundColor: .systemBackground,
            titleColor: .label,
            isTranslucent: false
        )
    }
}
