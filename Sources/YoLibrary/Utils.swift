import UIKit

public class Utils {
    // MARK: - APNs デバッグ

    /// **APNs ペイロードを出力する（デバッグ用）**
    public static func postApnsPayload(_ userInfo: [String: Any?]) {
        let nonNilUserInfo = userInfo.compactMapValues { $0 }
        dump(nonNilUserInfo)
    }

    // MARK: - ローカライズ

    /// **ローカライズされた文字列を取得**
    public static func lstr(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    // MARK: - ナビゲーション & UI 操作

    /// **UIViewController のタイトルを設定**
    public static func setTitle(_ vc: UIViewController, title: String) {
        vc.title = title
    }

    /// **ナビゲーションバーのタイトルを設定**
    public static func setNavigationBar(_ vc: UIViewController, title: String) {
        if let navController = vc.navigationController {
            navController.navigationBar.topItem?.title = title
        } else {
            vc.title = title
        }
    }

    /// **背景色を設定**
    public static func setBackgroundColor(_ vc: UIViewController, color: UIColor) {
        vc.view.backgroundColor = color
    }

    /// **ナビゲーションバーの外観を設定**
    public static func setNavigationBarAppearance(_ nav: UINavigationController?, backgroundColor: UIColor, titleColor: UIColor, isTranslucent: Bool = false) {
        guard let navBar = nav?.navigationBar else { return }

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: titleColor]

        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.isTranslucent = isTranslucent
    }

    /// **戻るボタンを追加**
    public static func addBackButton(_ vc: UIViewController, title: String = "Back") {
        let backButton = UIBarButtonItem(title: title, style: .plain, target: vc, action: #selector(vc.goBack))
        vc.navigationItem.leftBarButtonItem = backButton
    }

    /// **UINavigationController にラップ**
    public static func embedInNavigationController(_ vc: UIViewController) -> UINavigationController {
        UINavigationController(rootViewController: vc)
    }

    // MARK: - ローディング表示

    private static var loadingIndicator: UIActivityIndicatorView?

    /// **ローディングを表示**
    public static func showLoading(in vc: UIViewController) {
        DispatchQueue.main.async {
            if loadingIndicator == nil {
                let indicator = UIActivityIndicatorView(style: .large)
                indicator.center = vc.view.center
                indicator.hidesWhenStopped = true
                vc.view.addSubview(indicator)
                loadingIndicator = indicator
            }
            loadingIndicator?.startAnimating()
        }
    }

    /// **ローディングを非表示**
    public static func hideLoading() {
        DispatchQueue.main.async {
            loadingIndicator?.stopAnimating()
            loadingIndicator?.removeFromSuperview()
            loadingIndicator = nil
        }
    }

    // MARK: - アラート & トースト表示

    /// **アラートを表示**
    public static func showAlert(
        on vc: UIViewController,
        title: String,
        message: String,
        okTitle: String = "OK",
        cancelTitle: String? = nil,
        okAction: (() -> Void)? = nil,
        cancelAction: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okTitle, style: .default, handler: { _ in okAction?() }))

        if let cancelTitle {
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { _ in cancelAction?() }))
        }

        vc.present(alert, animated: true, completion: nil)
    }

    /// **エラーメッセージを表示**
    public static func showErrorAlert(on vc: UIViewController, message: String, handler: (() -> Void)? = nil) {
        showAlert(on: vc, title: "エラー", message: message, okTitle: "閉じる", okAction: handler)
    }

    /// **トーストメッセージを表示**
    public static func showToast(on vc: UIViewController, message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel(frame: CGRect(x: 0, y: 0, width: vc.view.frame.width - 40, height: 50))
        toastLabel.center = CGPoint(x: vc.view.center.x, y: vc.view.frame.height - 100)
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        toastLabel.text = message
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true

        vc.view.addSubview(toastLabel)

        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }

    /// **URL を開く**
    public static func openURL(_ urlString: String) {
        guard urlString.isValidURL else {
            print("⚠️ 開けない URL: \(urlString)")
            return
        }

        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            print("⚠️ `UIApplication.shared.canOpenURL(url)` が `false` です。`LSApplicationQueriesSchemes` の設定を確認してください。")
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    // MARK: - RootViewController 切り替え

    /// **RootViewController を変更（アニメーションあり）**
    public static func setRootViewController(_ viewController: UIViewController, animated: Bool = true) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else {
            print("⚠️ RootViewControllerの変更に失敗: UIWindowが見つかりません")
            return
        }

        if animated {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = viewController
            }, completion: nil)
        } else {
            window.rootViewController = viewController
        }
        window.makeKeyAndVisible()
    }

    // MARK: - ダークモード判定

    /// **現在のテーマがダークモードか判定**
    public static func isDarkMode(_ vc: UIViewController) -> Bool {
        vc.traitCollection.userInterfaceStyle == .dark
    }

    // MARK: - キーボード操作

    /// **キーボードを閉じる**
    public static func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: - スクリーンショット撮影

    /// **スクリーンショットを取得**
    public static func captureScreenshot(of view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    // MARK: - Haptic フィードバック

    /// **Haptic フィードバックを実行**
    public static func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
