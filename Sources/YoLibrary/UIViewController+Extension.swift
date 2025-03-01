import UIKit

public extension UIViewController {
    /// **ナビゲーションコントローラで戻る**
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
}
