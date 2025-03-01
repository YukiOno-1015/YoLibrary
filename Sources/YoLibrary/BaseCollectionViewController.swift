import UIKit

/// **すべての CollectionViewController のベースとなるクラス**
open class BaseCollectionViewController: UICollectionViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    open func setupUI() {
        Utils.setBackgroundColor(self, color: .systemBackground)
    }

    open func setupNavigationBar() {
        Utils.setNavigationBar(self, title: title ?? "")
    }

    open func bindViewModel() {}
}
