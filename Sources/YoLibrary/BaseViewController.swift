import UIKit

/// **すべての ViewController のベースとなるクラス**
open class BaseViewController: UIViewController {
    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    // MARK: - UI セットアップ（オーバーライド可能）

    /// **UI の共通セットアップ**
    open func setupUI() {
        Utils.setBackgroundColor(self, color: .systemBackground)
    }

    /// **ナビゲーションバーのセットアップ**
    open func setupNavigationBar() {
        Utils.setNavigationBar(self, title: title ?? "")
    }

    /// **ViewModel のバインド（オーバーライドして使用）**
    open func bindViewModel() {}

    // MARK: - ローディング表示

    public func showLoading() {
        Utils.showLoading(in: self)
    }

    public func hideLoading() {
        Utils.hideLoading()
    }

    // MARK: - アラート & トースト表示

    public func showAlert(title: String, message: String, okTitle: String = "OK", cancelTitle: String? = nil, okAction: (() -> Void)? = nil, cancelAction: (() -> Void)? = nil) {
        Utils.showAlert(on: self, title: title, message: message, okTitle: okTitle, cancelTitle: cancelTitle, okAction: okAction, cancelAction: cancelAction)
    }

    public func showErrorAlert(message: String, handler: (() -> Void)? = nil) {
        Utils.showErrorAlert(on: self, message: message, handler: handler)
    }

    public func showToast(message: String, duration: TimeInterval = 2.0) {
        Utils.showToast(on: self, message: message, duration: duration)
    }

    // MARK: - ルート画面変更

    public func setRootViewController(_ vc: UIViewController, animated: Bool = true) {
        Utils.setRootViewController(vc, animated: animated)
    }

    // MARK: - ダークモード対応

    public var isDarkMode: Bool {
        Utils.isDarkMode(self)
    }

    // MARK: - キーボード操作

    public func dismissKeyboard() {
        Utils.dismissKeyboard()
    }

    // MARK: - スクリーンショット撮影

    public func captureScreenshot() -> UIImage? {
        Utils.captureScreenshot(of: view)
    }

    // MARK: - Haptic フィードバック

    public func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        Utils.triggerHapticFeedback(style: style)
    }
}
