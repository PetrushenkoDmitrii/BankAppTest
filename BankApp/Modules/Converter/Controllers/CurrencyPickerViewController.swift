import UIKit

protocol CurrencyPickerDelegate: AnyObject {
    func currencyPicker(_ picker: CurrencyPickerViewController, didSelect currency: Currency)
}

final class CurrencyPickerViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    private enum Section: Int, CaseIterable {
        case fiat, crypto
        var title: String { self == .fiat ? "Фиат" : "Криптовалюты" }
    }

    private var data: [Section: [Currency]]
    private var filtered: [Section: [Currency]]

    weak var delegate: CurrencyPickerDelegate?

    private let searchBar = UISearchBar(frame: .zero)
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(fiat: [Currency], crypto: [Currency]) {
        self.data = [.fiat: fiat, .crypto: crypto]
        self.filtered = self.data
        super.init(nibName: nil, bundle: nil)
        title = "Выбор валюты"
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.placeholder = "Поиск по коду или названию"
        searchBar.searchBarStyle = .minimal
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.isTranslucent = true
        searchBar.delegate = self

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 56
        tableView.sectionHeaderTopPadding = 8
        tableView.dataSource = self
        tableView.delegate = self

        let stack = UIStackView(arrangedSubviews: [searchBar, tableView])
        stack.axis = .vertical
        stack.spacing = 8
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange text: String) {
        updateFiltered(query: text)
    }

    private func updateFiltered(query: String) {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { filtered = data; tableView.reloadData(); return }

        func match(_ c: Currency) -> Bool {
            c.code.lowercased().contains(q) || c.name.lowercased().contains(q)
        }
        filtered[.fiat]   = (data[.fiat]   ?? []).filter(match)
        filtered[.crypto] = (data[.crypto] ?? []).filter(match)
        tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section(rawValue: section)?.title
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let hv = view as? UITableViewHeaderFooterView {
            hv.contentView.backgroundColor = .clear
            hv.backgroundView = nil
            hv.textLabel?.textColor = UIColor.white.withAlphaComponent(0.9)
        }
    }

    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        (filtered[Section(rawValue: section)!] ?? []).count
    }

    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "cell"
        let cell = tv.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .subtitle, reuseIdentifier: id)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none

        let section = Section(rawValue: indexPath.section)!
        let c = (filtered[section] ?? [])[indexPath.row]

        var conf = UIListContentConfiguration.subtitleCell()
        conf.text = c.code
        conf.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)
        conf.textProperties.color = .white

        conf.secondaryText = c.name
        conf.secondaryTextProperties.font = .systemFont(ofSize: 13)
        conf.secondaryTextProperties.color = UIColor.white.withAlphaComponent(0.78)

        conf.imageProperties.maximumSize = CGSize(width: 28, height: 28)
        conf.image = CryptoIcon.isKnown(c.code)
            ? CryptoIcon.image(for: c.code, diameter: 28)
            : FlagIcon.image(emoji: c.flag, diameter: 28)

        cell.contentConfiguration = conf
        return cell
    }

    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        tv.deselectRow(at: indexPath, animated: true)
        let section = Section(rawValue: indexPath.section)!
        if let item = (filtered[section] ?? []).element(at: indexPath.row) {
            delegate?.currencyPicker(self, didSelect: item)
        }
    }
}

private extension Array {
    func element(at index: Int) -> Element? { indices.contains(index) ? self[index] : nil }
}
