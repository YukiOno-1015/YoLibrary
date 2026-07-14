import UIKit

/// **汎用ユーティリティクラス**
/// UI 操作のユーティリティ。
///
/// **`@MainActor` にした理由**: 中身はほぼ UIKit の操作で、メインスレッド
/// 以外から呼ぶと未定義動作になる。以前は `DispatchQueue.main.async` を
/// 各所に散らしていたが、それは「呼び出し側が間違えても救う」だけで、
/// 間違いを防げない。型で縛れば、そもそも間違った場所から呼べなくなる。
///
/// `enum` にしているのは、インスタンス化する意味が無いため
/// （`class` だと `Utils()` と書けてしまう）。
@MainActor
public enum Utils {
    // MARK: - 🚀 APNs デバッグ

    /// **APNs ペイロードを出力（デバッグ用）**
    ///
    /// - Parameter userInfo: APNs の受信情報（`[String: Any?]`）
    public static func postApnsPayload(_ userInfo: [String: Any?]) {
        let nonNilUserInfo = userInfo.compactMapValues { $0 }
        dump(nonNilUserInfo)
    }

    // MARK: - 🌎 ローカライズ

    /// **ローカライズされた文字列を取得**
    ///
    /// - Parameters:
    ///   - key: `Localizable.strings` に定義されたキー
    ///   - bundle: 取得対象の `Bundle`（デフォルトは `nil`）
    /// - Returns: ローカライズされた文字列（存在しない場合は `key` をそのまま返す）
    /// UI 操作ではないので nonisolated。どのスレッドからでも呼べる
    /// （エラーメッセージの組み立てなど、バックグラウンドから呼ぶ場面がある）。
    nonisolated public static func localized(_ key: String, bundle: Bundle? = nil) -> String {
        let string = NSLocalizedString("\(key)", bundle: bundle ?? Bundle.main, comment: "")
        return string == "\(key)" ? "[\(key)]" : string // 未翻訳なら `"[key]"` を返す
    }

    // MARK: - 🎨 UI & ナビゲーション設定

    /// **`UIViewController` のタイトルを設定**
    public static func setTitle(_ vc: UIViewController, title: String) {
        vc.title = title
    }

    /// **ナビゲーションバーのタイトルを設定**
    public static func setNavigationBar(_ vc: UIViewController, title: String) {
        vc.navigationController?.navigationBar.topItem?.title = title
    }

    /// **背景色を設定**
    public static func setBackgroundColor(_ vc: UIViewController, color: UIColor) {
        vc.view.backgroundColor = color
    }

    public static func setNavigationBarAppearance(
        _ nav: UINavigationController?,
        backgroundColor: UIColor,
        titleColor: UIColor,
        titleFont: UIFont = UIFont.systemFont(ofSize: 17), // フォントサイズ変更を追加
        isTranslucent: Bool = false
    ) {
        guard let navBar = nav?.navigationBar else { return }

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = [
            .foregroundColor: titleColor,
            .font: titleFont,
        ]

        navBar.standardAppearance = appearance
        // スクロールで隠れる状態でも同じ見た目にする。
        // 設定しないと、スクロール先頭で背景が透明になり色が消える。
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance

        navBar.isTranslucent = isTranslucent
    }

    /// **戻るボタンを追加**
    public static func addBackButton(_ vc: UIViewController, title: String = "Back") {
        let backButton = UIBarButtonItem(title: title, style: .plain, target: vc, action: #selector(vc.goBack))
        vc.navigationItem.leftBarButtonItem = backButton
    }

    /// **`UINavigationController` にラップ**
    public static func embedInNavigationController(_ vc: UIViewController) -> UINavigationController {
        UINavigationController(rootViewController: vc)
    }

    // MARK: - ⏳ ローディング表示

    /// 表示中のローディング。@MainActor なのでロック不要。
    private static var loadingIndicator: UIActivityIndicatorView?

    /// **ローディングを表示**
    ///
    /// - Parameter vc: 表示先の ViewController。
    public static func showLoading(in vc: UIViewController) {
        Logger.debug(message: "UIViewController: \(vc.title ?? "")")

        // @MainActor なので DispatchQueue.main.async で包まない。
        // 包むと 1 フレーム遅れ、直後に hideLoading() を呼んだときに
        // 表示と非表示の順序が入れ替わって「消えないローディング」になる。
        guard let targetView = vc.navigationController?.view ?? vc.view else {
            Logger.debug(message: "ローディング表示対象のビューが見つかりません")
            return
        }

        if loadingIndicator == nil {
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            // 明暗どちらでも見える色。自前で白黒を切り替えると、
            // ダークモードの切り替えに追従できない。
            indicator.color = .label
            indicator.hidesWhenStopped = true

            targetView.addSubview(indicator)

            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: targetView.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: targetView.centerYAnchor),
            ])

            loadingIndicator = indicator
        }

        loadingIndicator?.startAnimating()
    }

    /// **ローディングを非表示**
    public static func hideLoading() {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.removeFromSuperview()
        loadingIndicator = nil
    }

    // MARK: - ⚠️ アラート & トースト表示

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
    public static func showErrorAlert(
        on vc: UIViewController,
        message: String,
        handler: (() -> Void)? = nil
    ) {
        let bundle = Bundle.yoLibrary

        showAlert(
            on: vc,
            title: Utils.localized("error", bundle: bundle),
            message: message,
            okTitle: Utils.localized("close", bundle: bundle),
            okAction: handler
        )
    }

    /// **トーストメッセージを表示**
    ///
    /// - Parameters:
    ///   - vc: `UIViewController`（表示する画面）
    ///   - message: 表示するメッセージ
    ///   - duration: 表示時間（デフォルト: `2.0`秒）
    public static func showToast(on vc: UIViewController, message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel(frame: CGRect(
            x: 20,
            y: vc.view.frame.height - 120,
            width: vc.view.frame.width - 40,
            height: 50
        ))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = .white
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

    // MARK: - 🔗 URL 操作

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

    // MARK: - 📱 RootViewController 切り替え（iOS 15 未満 & 以上対応）

    /// **RootViewController を変更（アニメーションあり）**
    public static func setRootViewController(_ viewController: UIViewController, animated: Bool = true) {
        guard let window = Screen.keyWindow else {
            Logger.debug(message: "RootViewController の変更に失敗: UIWindow が見つかりません")
            return
        }

        if animated {
            // いきなり差し替えると何が起きたか分からない。クロスフェードで繋ぐ。
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                window.rootViewController = viewController
            }
        } else {
            window.rootViewController = viewController
        }
        window.makeKeyAndVisible()
    }

    // MARK: - 🌐 タブバーの外観設定

    /// **タブバーの外観を設定**
    ///
    /// - Parameters:
    ///   - tabBarController: 対象の `UITabBarController`
    ///   - backgroundColor: 背景色
    ///   - tintColor: アイコン・選択時の色
    ///   - isTranslucent: 半透明フラグ（デフォルト: `false`）
    public static func setTabBarAppearance(
        _ tabBarController: UITabBarController,
        backgroundColor: UIColor,
        tintColor: UIColor,
        isTranslucent: Bool = false
    ) {
        let tabBar = tabBarController.tabBar
        tabBar.backgroundColor = backgroundColor
        tabBar.tintColor = tintColor
        tabBar.isTranslucent = isTranslucent
    }

    // MARK: - 🌙 ダークモード判定

    /// **現在のテーマがダークモードか判定**
    public static func isDarkMode(_ vc: UIViewController) -> Bool {
        vc.traitCollection.userInterfaceStyle == .dark
    }

    // MARK: - 🎹 キーボード操作

    /// **キーボードを閉じる**
    public static func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: - 📸 スクリーンショット撮影

    /// **スクリーンショットを取得**
    /// - Parameter view: 撮影対象。
    /// - Returns: 撮影した画像。
    public static func captureScreenshot(of view: UIView) -> UIImage? {
        // UIGraphicsBeginImageContext 系は古い API。
        // UIGraphicsImageRenderer は解像度を自動で合わせ、色空間も正しく扱う。
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        return renderer.image { context in
            view.layer.render(in: context.cgContext)
        }
    }

    // MARK: - 🔔 Haptic フィードバック

    /// **Haptic フィードバックを実行**
    public static func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
