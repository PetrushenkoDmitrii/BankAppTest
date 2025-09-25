import UIKit

final class ConverterViewController: BaseViewController, CurrencyPickerDelegate {

    private let preview: ConverterPreviewView
    private let headerBar = UIStackView()
    private let historyTitle = UILabel()
    private let clearButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)

    private var bynPerUnit: [String: Double] = ["BYN": 1.0]
    private var usdUnit: Double?
    private var fiatCurrencies: [Currency] = []
    private var cryptoCurrencies: [Currency] = []
    private var history: [ConversionRecord] = []

    private let defaultBase = "USD"
    private let defaultQuote = "BYN"

    private var selectingBase = true

    init() {
        let byn = Currency(code: "BYN", name: "Белорусский рубль", symbol: "Br", flag: "🇧🇾")
        let usd = Currency(code: "USD", name: "Доллар США", symbol: "$", flag: "🇺🇸")
        let ex = ExchangeRate(base: usd, quote: byn, rate: 1.decimal, updatedAt: Date())
        self.preview = ConverterPreviewView(model: ConverterPreviewModel(amountBase: 0, rate: ex))
        super.init(nibName: nil, bundle: nil)
        title = "Конвертер"
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
        loadRates()
        reloadHistory()
    }

    private func setupUI() {
        view.addSubview(preview)
        preview.translatesAutoresizingMaskIntoConstraints = false

        historyTitle.text = "Недавние конвертации"
        historyTitle.font = .systemFont(ofSize: 16, weight: .semibold)
        historyTitle.textColor = .white

        clearButton.setTitle("Очистить", for: .normal)
        clearButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        clearButton.layer.cornerRadius = 10
        clearButton.configuration = { var clearButton = clearButton.configuration ?? .plain(); clearButton.contentInsets = .init(top: 6, leading: 12, bottom: 6, trailing: 12); return clearButton }()
        clearButton.addTarget(self, action: #selector(clearHistory), for: .touchUpInside)

        headerBar.axis = .horizontal
        headerBar.alignment = .center
        headerBar.spacing = 8
        headerBar.addArrangedSubview(historyTitle)
        headerBar.addArrangedSubview(UIView())
        headerBar.addArrangedSubview(clearButton)
        view.addSubview(headerBar)
        headerBar.translatesAutoresizingMaskIntoConstraints = false

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 68
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RecentConversionCell.self, forCellReuseIdentifier: "RecentConversionCell")
        let empty = UILabel()
        empty.text = "Нет конвертаций — начните выше"
        empty.textColor = UIColor.white.withAlphaComponent(0.65)
        empty.font = .systemFont(ofSize: 14, weight: .medium)
        empty.textAlignment = .center
        tableView.backgroundView = empty

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            preview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            preview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            preview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),

            headerBar.topAnchor.constraint(equalTo: preview.bottomAnchor, constant: 16),
            headerBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: headerBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bindActions() {
        preview.onSelectBase  = { [weak self] in self?.openPicker(isBase: true) }
        preview.onSelectQuote = { [weak self] in self?.openPicker(isBase: false) }
    }

    private func loadRates() {
        RatesProvider.shared.loadFiatTop10 { [weak self] fiats, usdUnit in
            guard let self = self else { return }
            self.usdUnit = usdUnit

            self.fiatCurrencies = self.makeFiatCurrencies(from: fiats)

            self.bynPerUnit = fiats.reduce(into: ["BYN": 1.0]) { dict, r in
                dict[r.currency] = r.value
            }

            CryptoRatesProvider.shared.loadTopCrypto { [weak self] cryptos in
                guard let self = self else { return }
                self.cryptoCurrencies = self.makeCryptoCurrencies(from: cryptos)
                if let usd = self.usdUnit {
                    for r in cryptos { self.bynPerUnit[r.currency] = r.value * usd }
                }
                DispatchQueue.main.async { self.applyDefaultCurrencies() }
            }
        }
    }

    private func applyDefaultCurrencies() {
        if let base = currency(by: defaultBase), let quote = currency(by: defaultQuote) {
            updateRate(base: base, quote: quote)
        }
    }

    private func openPicker(isBase: Bool) {
        selectingBase = isBase
        let picker = CurrencyPickerViewController(fiat: fiatCurrencies, crypto: cryptoCurrencies)
        picker.delegate = self
        let nav = UINavigationController(rootViewController: picker)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }

    func currencyPicker(_ picker: CurrencyPickerViewController, didSelect currency: Currency) {
        picker.dismiss(animated: true)
        let base  = selectingBase ? currency : preview.model.baseCurrency
        let quote = selectingBase ? preview.model.quoteCurrency : currency
        updateRate(base: base, quote: quote)
    }

    private func updateRate(base: Currency, quote: Currency) {
        guard let rate = rateBYN(base: base.code, quote: quote.code) else { return }
        let ex = ExchangeRate(base: base, quote: quote, rate: rate.decimal, updatedAt: Date())
        preview.model = ConverterPreviewModel(amountBase: preview.model.amountBase, rate: ex)
        saveHistoryIfNeeded(using: rate)
    }

    private func rateBYN(base: String, quote: String) -> Double? {
        guard let b = bynPerUnit[base], let q = bynPerUnit[quote] else { return nil }
        return b / q
    }

    private func saveHistoryIfNeeded(using rate: Double) {
        let amountBase = NSDecimalNumber(decimal: preview.model.amountBase).doubleValue
        guard amountBase > 0 else { return }
        let amountQuote = amountBase * rate

        let rec = ConversionRecord(
            baseCode:  preview.model.baseCurrency.code,
            baseFlag:  preview.model.baseCurrency.flag,
            quoteCode: preview.model.quoteCurrency.code,
            quoteFlag: preview.model.quoteCurrency.flag,
            amountBase: amountBase,
            amountQuote: amountQuote,
            rate: rate,
            timestamp: Date()
        )
        ConversionHistoryStore.shared.add(rec)
        reloadHistory()
    }

    private func reloadHistory() {
        history = ConversionHistoryStore.shared.load()
        (tableView.backgroundView as? UILabel)?.isHidden = !history.isEmpty
        tableView.reloadData()
    }

    @objc private func clearHistory() {
        ConversionHistoryStore.shared.clear()
        reloadHistory()
    }

    private func currency(by code: String) -> Currency? {
        (fiatCurrencies + cryptoCurrencies + [Currency(code: "BYN", name: "Белорусский рубль", symbol: "Br", flag: "🇧🇾")])
            .first { $0.code == code }
    }

    private func makeFiatCurrencies(from rates: [Rate]) -> [Currency] {
        var all = [Currency(code: "BYN", name: "Белорусский рубль", symbol: "Br", flag: "🇧🇾")]
        all.append(contentsOf: rates.map { r in
            Currency(code: r.currency,
                     name: CurrenciesMeta.fiatName[r.currency] ?? r.currency,
                     symbol: CurrenciesMeta.fiatSymbol[r.currency] ?? r.currency,
                     flag: CurrenciesMeta.flag[r.currency] ?? "🏳️")
        })
        var seen = Set<String>(); var out: [Currency] = []
        for c in all where seen.insert(c.code).inserted { out.append(c) }
        return out
    }

    private func makeCryptoCurrencies(from rates: [Rate]) -> [Currency] {
        rates.map { r in
            Currency(code: r.currency,
                     name: CurrenciesMeta.cryptoName[r.currency] ?? r.currency,
                     symbol: r.currency,
                     flag: "🪙")
        }
    }
}

extension ConverterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int { history.count }

    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "RecentConversionCell", for: indexPath) as! RecentConversionCell
        cell.configure(with: history[indexPath.row])
        return cell
    }

    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        tv.deselectRow(at: indexPath, animated: true)
        let rec = history[indexPath.row]
        guard let base = currency(by: rec.baseCode),
              let quote = currency(by: rec.quoteCode),
              let rate = rateBYN(base: base.code, quote: quote.code) else { return }

        let ex = ExchangeRate(base: base, quote: quote, rate: rate.decimal, updatedAt: Date())
        preview.model = ConverterPreviewModel(amountBase: rec.amountBase.decimal, rate: ex)
    }

    func tableView(_ tv: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _,_,finish in
            ConversionHistoryStore.shared.remove(at: indexPath.row)
            self?.reloadHistory()
            finish(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

private extension Double { var decimal: Decimal { Decimal(self) } }
