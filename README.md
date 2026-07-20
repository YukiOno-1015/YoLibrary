# YoLibrary

iOS アプリを書くたびに毎回書き直していたものをまとめた、自分用の共通ライブラリ。

Swift 6（strict concurrency）に対応済み。data race を型システムで防ぐ。

## 入れ方

```swift
.package(id: "YukiOno-1015.YoLibrary", from: "1.2.1")
```

Nexus の Swift registry を先に向ける。`swift-group`（`swift-hosted` + `swift-proxy` を束ねた group
リポジトリ）を指定する。ホストは `nexus-cli.sk4869.info`（`nexus.sk4869.info` は Cloudflare Zero
Trust 認証があり CLI からは通らない）。

```bash
swift package-registry set "https://nexus-cli.sk4869.info/repository/swift-group/"
swift package-registry login https://nexus-cli.sk4869.info/repository/swift-hosted/login \
    --username=<NEXUS_CLI_USERNAME> \
    --password=<NEXUS_CLI_PASSWORD>
```

CI でも SSH ではなく registry 経由で引く前提に変える。

パッケージ ID (`YukiOno-1015.YoLibrary`) は Nexus の SCM→registry 自動マッピングが
`https://github.com/YukiOno-1015/YoLibrary.git` から導出する識別子と一致させてある。
publish 時に別の ID（例: `yukiono.yolibrary`）を使うと、`url:` 形式で参照している
consumer 側からレジストリが自動解決できなくなる。

| 項目 | 値 |
| --- | --- |
| Swift | 6.0（`.swiftLanguageMode(.v6)`） |
| iOS | 17.0 以上 |
| macOS | 14.0 以上 |
| tvOS | 17.0 以上 |
| watchOS | 10.0 以上 |

iOS 17 を下限にしているのは、Observation（`@Observable`）と `UIContentUnavailableConfiguration` を使うため。前者があれば MVVM のバインドに RxSwift も Combine も要らず、後者があれば「空表示」「ローディング」を自前で書かずに済む。

## 何が入っているか

### OpenAPI ミドルウェア

[swift-openapi-generator](https://github.com/apple/swift-openapi-generator) と組み合わせて使う。**生成コードは API ごとに違うが、ミドルウェアは API に依存しない**ので、生成器を使うプロジェクトならどれでも使い回せる。

```swift
import OpenAPIRuntime
import OpenAPIURLSession
import YoLibrary

let client = Client(
    serverURL: baseURL,
    configuration: Configuration(dateTranscoder: LenientISO8601DateTranscoder()),
    transport: URLSessionTransport(),
    middlewares: [
        AuthMiddleware(tokenProvider: { try await auth.idToken() }),
        RequestIDMiddleware(),
        MaintenanceMiddleware(
            onDetected: { info in await MaintenanceMonitor.shared.enter(info) },
            onRecovered: { await MaintenanceMonitor.shared.leave() }
        ),
        RetryMiddleware(),
        LoggingMiddleware(),
    ]
)
```

順番に意味がある。リトライを認証より内側に置くのは、やり直すたびにトークンを取り直すと無駄が出るため。ログを一番内側に置くのは、実際に飛んだ回数ぶん記録したいため（リトライが見えなくなると困る）。

| ミドルウェア | 役割 |
| --- | --- |
| `AuthMiddleware` | 全リクエストに `Authorization: Bearer` を付ける。トークンの取得と更新はアプリ側の責務にしてあり、ライブラリは Firebase や OAuth を知らない |
| `RequestIDMiddleware` | `X-Request-ID` を付ける。サーバーログの `trace.id` と突き合わせるため。これが無いと「アプリでエラーが出た」からサーバーのどのログを見ればいいか分からない |
| `LoggingMiddleware` | リクエストとレスポンスを記録する。認証ヘッダは出さない（トークンがログに残ると、それ自体が漏洩経路になる） |
| `RetryMiddleware` | 一時的な失敗をやり直す。GET かつボディ無しに限る。503 もやり直さない |
| `MaintenanceMiddleware` | サーバーのメンテナンス（HTTP 503）を検知する |

`RetryMiddleware` を GET 限定にしたのは、POST を再送すると 1 回目が実際には成功していた場合に二重登録になるため。HTTP は「届いたが応答が返らなかった」を区別できない。

#### LenientISO8601DateTranscoder

**swift-openapi-runtime の既定の日付変換は小数秒を受け付けない。**

```text
2026-07-13T23:39:21Z        → 読める
2026-07-13T23:39:21.402569Z → DecodingError.dataCorrupted
```

ところが FastAPI / Pydantic はマイクロ秒付きで返す。Go や Java も同様の実装が多い。つまり既定のままだと、よくあるサーバーの応答がそのままでは decode できない。エラーは `Expected date string to be ISO8601-formatted.` としか出ず、どのフィールドが原因か分からない。

サーバー側で小数秒を削るのは情報を捨てることになるので、**読む側を寛容にする**。書き出すときは小数秒を付けない（受け取れないサーバー実装があるため、送るデータは最も素直な形に寄せる）。

#### MaintenanceMiddleware

API の呼び出し 1 本ずつに 503 の処理を書かせない。各画面で `statusCode == 503` を書くと、**必ずどこかで書き漏らして「その画面だけ意味不明なエラーが出る」**ことになる。入口で一度だけ捕まえる。

- 503 の本文（文言・終了予定）と `Retry-After` ヘッダを読む
- 本文が空・壊れていてもメンテ扱いは続ける。503 という事実の方が重い
- 503 はそのまま下流にも流す。握り潰すと呼び出し元がエラーを検知できず、画面が「読み込み中」のまま止まる

`RetryMiddleware` が 503 をやり直さないのはこのため。5xx の中で 503 だけは「意図的に閉じている」意味を持つ（メンテナンス・過負荷）。サーバーが `Retry-After` で「いつ来い」と指示しているのに叩き直したら、復旧作業中のサーバーに負荷を掛けるだけになる。500 / 502 / 504 は従来どおりやり直す。

サーバー側は 503 + JSON + `Retry-After` を返す想定。

```json
{
  "status": "maintenance",
  "message": "システムメンテナンス中です。",
  "message_en": "Under maintenance.",
  "until": "2026-07-15T03:00:00Z"
}
```

### APIClient

OpenAPI の仕様書が**無い** API 向け。仕様書があるなら生成器を使うべきで、こちらは使わない。

```swift
let client = APIClient(baseURL: url, auth: MyTokenProvider())
let user: User = try await client.request(path: "/me", method: .get)
```

認証方式は `AuthTokenProvider` で注入する。ライブラリが特定の認証基盤に縛られないようにするため。

`JSONDecoder.yoDefault` には snake_case → camelCase の変換と、小数秒の有無どちらの ISO8601 も読む設定が入っている。

### ベースクラス

UIKit のコードベース開発で、毎回書く定型を引き受ける。

| クラス | 中身 |
| --- | --- |
| `BaseViewController` | `setupUI()` / `bindViewModel()` のフック、`showLoading()`、`showAlert()`、`showToast()`、`triggerHapticFeedback()` |
| `BaseNavigationController` | ナビゲーションバーの見た目を standard / scrollEdge / compact で揃える |
| `BaseTableViewController` | Pull-to-Refresh とセル高の自動計算をあらかじめ設定 |
| `BaseCollectionViewController` | 同上 |
| `BaseTabBarController` | タブバーの見た目 |
| `BaseTableViewCell` | XIB 用。`awakeFromNib` → `configureView()` |

`viewDidLoad` に全部詰め込むのをやめ、`setupUI()`（画面の組み立て）と `bindViewModel()`（状態の監視）に分ける。ライフサイクルの呼び出し順は基底が面倒を見る。

`BaseNavigationController` は見た目の実害を潰すためのもの。素の `UINavigationController` はスクロール先頭でバーの背景が透明になるが、こちらは 3 つの appearance を揃えるので色が抜けない。

### Logger

`os_log` の薄いラッパー。カテゴリ（ui / api / network / database / auth / other）とレベルを持つ。

```swift
Logger.info(category: .api, message: "GET /me → 200")
Logger.error(category: .auth, message: "ログイン失敗: \(error.localizedDescription)")

// 配布ビルドでは黙らせる
#if !DEBUG
    Logger.isLoggingEnabled = false
#endif
```

**トークン類は出さないこと。** ID トークン・APNs デバイストークン・ユーザー識別子は、ログの共有経路から漏れるとなりすましや通知の狙い撃ちに使える。

### Screen

画面サイズなど。

```swift
Screen.width          // 実際に表示中の window から取る
Screen.safeAreaInsets
Screen.hasNotch
Screen.isPad
```

`UIScreen.main` は iOS 16 で非推奨。マルチウィンドウでは「どの画面か」が一意に決まらないため、表示中の window から取る。

値を `static let` で持たない理由は、**Split View・Stage Manager・画面回転で平気で変わる**から。定数にすると画面を分割した瞬間に嘘の値を返す。

### その他

`Utils`（アラート・トースト・ローディング・ハプティクス）と、`Date` / `String` / `Locale` / `TimeZone` / `UIColor` / `UIDevice` / `Bundle` の拡張。

## Swift 6 について

`SWIFT_STRICT_CONCURRENCY: complete` の利用側から安全に使えるよう、ライブラリ側で先に潰してある。ライブラリが Swift 5 モードのままだと、利用側がいくら厳しくしても「呼べてしまうが安全ではない」API を渡すことになる。

- UI に触るものは `@MainActor`（`Utils` / `Screen` / ベースクラス）
- `DateFormatter` など、スレッドセーフだが `Sendable` でない共有インスタンスは `nonisolated(unsafe)`
- `Logger.isLoggingEnabled` は `NSLock` で保護

## 開発

```bash
xcodebuild -scheme YoLibrary -destination 'generic/platform=iOS Simulator' build
```

`swift build` は使えない。ホスト（macOS）向けにビルドされるため、UIKit が見つからず落ちる。

## 変更履歴

| バージョン | 内容 |
| --- | --- |
| 1.2.1 | 503 をリトライしないよう修正 |
| 1.2.0 | `MaintenanceMiddleware`（メンテナンス検知）を追加 |
| 1.1.0 | `LenientISO8601DateTranscoder`（小数秒つき ISO8601）を追加 |
| 1.0.0 | Swift 6 対応、iOS 17 以上へ引き上げ、`APIClient` を async/await へ全面書き換え、OpenAPI ミドルウェアを追加 |
