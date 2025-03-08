//
//  BaseTableViewCell.swift
//  YoLibrary
//
//  Created by honoka on 2025/03/08.
//

import UIKit

/// `UITableViewCell` の基底クラス。共通処理を提供。
open class BaseTableViewCell: UITableViewCell {
    /// セルがインスタンス化された後のセットアップ処理
    override public func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }

    /// セルの選択状態が変更された際の処理
    /// - Parameters:
    ///   - selected: 選択状態
    ///   - animated: アニメーションの有無
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    /// セルのUIを初期化するためのメソッド
    /// サブクラスでオーバーライドしてカスタマイズ可能
    open func configureView() {
        // UIカスタマイズ処理をここに追加
    }
}
