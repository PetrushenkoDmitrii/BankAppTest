import UIKit

final class RatesViewController: BaseViewController {

    private enum Mode { case fiat, crypto }
    private var mode: Mode = .fiat
    private var display: DisplayCurrency = .byn

    private let modeControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Фиат", "Крипто"])
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        sc.selectedSegmentTintColor = .systemOrange
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        return sc
    }()

    private let displayControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["BYN", "USD"])
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        sc.selectedSegmentTintColor = .systemOrange
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        return sc
    }()

    private let tableView = UITableView(frame: .zero, style: .plain)

    private var usdUnit: Double?      
    private var fiatRates: [Rate] = []
    private var cryptoRates: [Rate] = []
    private var rows: [CurrencyRow] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Курсы валют"
        setupLayout()
        bind()
        loadFiat()
        loadCrypto()
    }

    private func setupLayout() {
        let top = UIStackView(arrangedSubviews: [modeControl, displayControl])
        top.axis = .horizontal; top.spacing = 12; top.distribution = .fillEqually

        view.addSubview(top)
        top.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            top.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            top.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            top.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 72
        tableView.register(RateRowCell.self, forCellReuseIdentifier: "RateRowCell")
        tableView.dataSource = self

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: top.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bind() {
        modeControl.addTarget(self, action: #selector(onModeChanged), for: .valueChanged)
        displayControl.addTarget(self, action: #selector(onDisplayChanged), for: .valueChanged)
    }

    private func loadFiat() {
        RatesProvider.shared.loadFiatTop10 { [weak self] rates, usdUnit in
            guard let self else { return }
            self.usdUnit = usdUnit
            self.fiatRates = rates
            DispatchQueue.main.async { self.rebuildRows() }
        }
    }

    private func loadCrypto() {
        CryptoRatesProvider.shared.loadTopCrypto { [weak self] rates in
            guard let self else { return }
            self.cryptoRates = Array(rates.prefix(10))
            DispatchQueue.main.async { self.rebuildRows() }
        }
    }

    @objc private func onModeChanged() {
        mode = (modeControl.selectedSegmentIndex == 0) ? .fiat : .crypto
        rebuildRows()
    }
    @objc private func onDisplayChanged() {
        display = (displayControl.selectedSegmentIndex == 0) ? .byn : .usd
        rebuildRows()
    }

    private func rebuildRows() {
        rows = (mode == .fiat)
            ? fiatRates.map { CurrencyRow.fiat(from: $0, display: display, usdUnit: usdUnit) }
            : cryptoRates.map { CurrencyRow.crypto(from: $0, display: display, usdUnit: usdUnit) }
        tableView.reloadData()
    }
}

extension RatesViewController: UITableViewDataSource {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }
    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "RateRowCell", for: indexPath) as! RateRowCell
        cell.configure(rows[indexPath.row])
        return cell
    }
}
