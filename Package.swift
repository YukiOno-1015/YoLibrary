// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "YoLibrary",
    defaultLocalization: "en",
    // iOS 17 以上に上げる。
    //
    // 理由:
    //   - Observation（@Observable）が使える。MVVM のバインドに RxSwift や
    //     Combine を持ち込まずに済む
    //   - UIContentUnavailableConfiguration など、自前で書いていた
    //     「空表示」「ローディング」を OS 標準に寄せられる
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
    ],
    products: [
        .library(
            name: "YoLibrary",
            targets: ["YoLibrary"]
        )
    ],
    dependencies: [
        // OpenAPI 生成コードと組み合わせるミドルウェアを提供するために要る。
        // 生成コード自体は各アプリが持つが、認証・ログ・リトライは共通化できる。
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.12.0"),
        // ClientMiddleware が扱う HTTPRequest / HTTPResponse の型。
        // OpenAPIRuntime の推移的依存だが、直接 import するので明示する
        // （暗黙の推移 import は将来の Swift で警告・エラーになる）。
        .package(url: "https://github.com/apple/swift-http-types", from: "1.4.0"),
    ],
    targets: [
        .target(
            name: "YoLibrary",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
            ],
            resources: [.process("Resources")],
            swiftSettings: [
                // Swift 6 の言語モード。data race を型システムで防ぐ。
                //
                // ライブラリが Swift 5 モードのままだと、利用側が
                // SWIFT_STRICT_CONCURRENCY: complete でも「呼べてしまうが
                // 安全ではない」API を渡すことになる。ライブラリ側で先に潰す。
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
