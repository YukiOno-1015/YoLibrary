import Foundation

// MARK: - TimeZone Extension

public extension TimeZone {
    /// 日本時間 (Asia/Tokyo)
    static let japan = TimeZone(identifier: "Asia/Tokyo")!

    /// UTC (協定世界時)
    static let utc = TimeZone(identifier: "UTC")!

    /// 現在のタイムゾーンの UTC オフセットを時間単位で取得
    var currentOffsetInHours: Int {
        secondsFromGMT() / 3600
    }

    /// 現在サマータイム (DST) かどうかを判定
    var isDaylightSavingTimeNow: Bool {
        isDaylightSavingTime()
    }

    /// `GMT+9:00` のようなフォーマットで UTC オフセットを取得
    var formattedOffset: String {
        let hours = currentOffsetInHours
        let minutes = (secondsFromGMT() % 3600) / 60
        return String(format: "GMT%+d:%02d", hours, minutes)
    }

    /// 利用可能なすべてのタイムゾーンの ID を取得
    static var allTimeZones: [String] {
        TimeZone.knownTimeZoneIdentifiers
    }
}
