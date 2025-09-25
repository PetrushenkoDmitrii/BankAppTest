import UIKit

final class RecentConversionCell: UITableViewCell {

    private let card = UIView()
    private let leftIcon  = UIImageView()
    private let rightIcon = UIImageView()
    private let leftTitle  = UILabel()
    private let rightTitle = UILabel()
    private let arrowLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        card.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        card.layer.cornerRadius = 16
        contentView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])

        [leftIcon, rightIcon].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.contentMode = .scaleAspectFit
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            $0.widthAnchor.constraint(equalToConstant: 28).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 28).isActive = true
        }

        [leftTitle, rightTitle].forEach {
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = .white
            $0.lineBreakMode = .byTruncatingTail
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }

        arrowLabel.text = "→"
        arrowLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        arrowLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        arrowLabel.setContentHuggingPriority(.required, for: .horizontal)
        arrowLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [leftIcon, leftTitle, arrowLabel, rightTitle, rightIcon])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 10

        card.addSubview(row)
        row.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            row.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            row.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            row.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with rec: ConversionRecord) {
        leftIcon.image  = icon(for: rec.baseCode, flag: rec.baseFlag)
        rightIcon.image = icon(for: rec.quoteCode, flag: rec.quoteFlag)
        leftTitle.text  = "\(Self.nf.string(from: NSNumber(value: rec.amountBase)) ?? "") \(rec.baseCode)"
        rightTitle.text = "\(Self.nf.string(from: NSNumber(value: rec.amountQuote)) ?? "") \(rec.quoteCode)"
    }

    private func icon(for code: String, flag: String) -> UIImage {
        CryptoIcon.isKnown(code) ? CryptoIcon.image(for: code, diameter: 28)
                                 : FlagIcon.image(emoji: flag, diameter: 28)
    }

    private static let nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 0
        nf.groupingSeparator = " "
        nf.decimalSeparator = ","
        return nf
    }()
}
