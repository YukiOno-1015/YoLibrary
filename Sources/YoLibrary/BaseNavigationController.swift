import UIKit

/// **すべての NavigationController のベースとなるクラス**
open class BaseNavigationController: UINavigationController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarAppearance()
    }

    open func setupNavigationBarAppearance() {
        Utils.setNavigationBarAppearance(self, backgroundColor: .systemBackground, titleColor: .label)
    }
}
