import UIKit

enum DisplayCurrency { case byn, usd }

struct CurrencyRow {
    let isCrypto: Bool
    let code: String
    let fullName: String
    let flagOrSymbol: String
    let priceText: String
    let changeText: String
    let changeColor: UIColor

    static func fiat(from rate: Rate, display: DisplayCurrency, usdUnit: Double?) -> CurrencyRow {
        let price: String
        switch display {
        case .byn:
            price = PriceFormatter.byn(rate.value, fractionDigits: 2)
        case .usd:
            guard let usdUnit else { price = "—"; break }
            let usd = rate.value / usdUnit
            price = PriceFormatter.usd(usd, fractionDigits: 2)
        }
        let pct = String(format: "%+.2f%%", rate.change)
        return .init(
            isCrypto: false,
            code: rate.currency,
            fullName: CurrenciesMeta.fiatName[rate.currency] ?? rate.currency,
            flagOrSymbol: CurrenciesMeta.flag[rate.currency] ?? "🏳️",
            priceText: price,
            changeText: pct,
            changeColor: rate.change == 0 ? UIColor.white.withAlphaComponent(0.6)
                                          : (rate.change > 0 ? .systemGreen : .systemRed)
        )
    }

    static func crypto(from rate: Rate, display: DisplayCurrency, usdUnit: Double?) -> CurrencyRow {
        let price: String
        switch display {
        case .usd:
            price = PriceFormatter.usd(rate.value, fractionDigits: 2)
        case .byn:
            guard let usdUnit else { price = "—"; break }
            price = PriceFormatter.byn(rate.value * usdUnit, fractionDigits: 2)
        }
        let code = rate.currency.uppercased()
        let pct = String(format: "%+.2f%%", rate.change)
        return .init(
            isCrypto: true,
            code: code,
            fullName: CurrenciesMeta.cryptoName[code] ?? code,
            flagOrSymbol: code, // сам бэйдж нарисует красивую иконку
            priceText: price,
            changeText: pct,
            changeColor: rate.change == 0 ? UIColor.white.withAlphaComponent(0.6)
                                          : (rate.change > 0 ? .systemGreen : .systemRed)
        )
    }
}

final class RateRowCell: UITableViewCell {
    private let card = UIView()
    private let badge = IconBadgeView()
    private let codeLabel = UILabel()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let changeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        card.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        card.layer.cornerRadius = 16
        contentView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])

        card.addSubview(badge)
        badge.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            badge.widthAnchor.constraint(equalToConstant: 36),
            badge.heightAnchor.constraint(equalToConstant: 36),
            badge.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            badge.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        codeLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        codeLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 13)
        nameLabel.textColor = UIColor.white.withAlphaComponent(0.85)

        let left = UIStackView(arrangedSubviews: [codeLabel, nameLabel])
        left.axis = .vertical; left.spacing = 2; left.alignment = .leading

        priceLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        priceLabel.textColor = .white; priceLabel.textAlignment = .right
        changeLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        changeLabel.textAlignment = .right

        let right = UIStackView(arrangedSubviews: [priceLabel, changeLabel])
        right.axis = .vertical; right.spacing = 2; right.alignment = .trailing

        let h = UIStackView(arrangedSubviews: [left, UIView(), right])
        h.axis = .horizontal; h.alignment = .center; h.spacing = 10

        card.addSubview(h)
        h.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            h.leadingAnchor.constraint(equalTo: badge.trailingAnchor, constant: 10),
            h.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            h.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            h.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10)
        ])
    }

    func configure(_ row: CurrencyRow) {
        codeLabel.text = row.code
        nameLabel.text = row.fullName
        priceLabel.text = row.priceText
        changeLabel.text = row.changeText
        changeLabel.textColor = row.changeColor

        if row.isCrypto { badge.configureCrypto(symbol: row.flagOrSymbol) }
        else { badge.configureFiat(flag: row.flagOrSymbol) }
    }
}
