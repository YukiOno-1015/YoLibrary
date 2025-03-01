import UIKit

/// **すべての `UITableViewController` のベースとなるクラス**
open class BaseTableViewController: UITableViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        bindViewModel()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    // MARK: - UI 設定

    /// **共通の UI 設定**
    open func setupUI() {
        Utils.setBackgroundColor(self, color: .systemBackground)
    }

    /// **NavigationBar の設定**
    open func setupNavigationBar() {
        Utils.setNavigationBar(self, title: title ?? "")
    }

    /// **TableView の共通設定**
    open func setupTableView() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        setupRefreshControl()
    }

    /// **Pull-to-Refresh を設定**
    open func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }

    /// **Pull-to-Refresh のアクション**
    @objc open func refreshData() {
        refreshControl?.endRefreshing()
    }

    // MARK: - ViewModel とのバインド

    /// **ViewModel をバインドする（必要があればオーバーライド）**
    open func bindViewModel() {}
}
