import UIKit

/// **すべての TableViewController のベースとなるクラス**
open class BaseTableViewController: UITableViewController {
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
        tableView.separatorStyle = .none
    }

    open func setupNavigationBar() {
        Utils.setNavigationBar(self, title: title ?? "")
    }

    open func bindViewModel() {}
}
