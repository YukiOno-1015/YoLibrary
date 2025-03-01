import UIKit

/// **すべての CollectionViewController のベースとなるクラス**
open class BaseCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    override public init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }

    /// `Storyboard` や `XIB` で使う場合の `init`
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        bindViewModel()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    /// **UI の共通設定**
    open func setupUI() {
        Utils.setBackgroundColor(self, color: .systemBackground)
    }

    /// **NavigationBar の共通設定**
    open func setupNavigationBar() {
        Utils.setNavigationBar(self, title: title ?? "")
    }

    /// **CollectionView の共通設定**
    open func setupCollectionView() {
        collectionView.collectionViewLayout = UICollectionViewFlowLayout() // FlowLayoutをデフォルトに
        collectionView.backgroundColor = .clear
    }

    /// **ViewModel をバインドする（必要があればオーバーライド）**
    open func bindViewModel() {}

    // MARK: - UICollectionViewDelegateFlowLayout

    /// **セルサイズのデフォルト設定（オーバーライド可能）**
    open func collectionView(
        _ collectionView: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt _: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 100) // デフォルトサイズ
    }

    /// **セクションの余白設定（オーバーライド可能）**
    open func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        insetForSectionAt _: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // デフォルトマージン
    }

    /// **セル間の余白設定（オーバーライド可能）**
    open func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        minimumLineSpacingForSectionAt _: Int
    ) -> CGFloat {
        10
    }

    open func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt _: Int
    ) -> CGFloat {
        10
    }
}
