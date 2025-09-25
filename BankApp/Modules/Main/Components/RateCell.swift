import UIKit

final class RateCell: UICollectionViewCell {
    private let flagLabel = UILabel()
    private let currencyLabel = UILabel()
    private let valueLabel = UILabel()
    private let changeLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6
        layer.masksToBounds = false

        flagLabel.font = .systemFont(ofSize: 24)
        currencyLabel.font = .boldSystemFont(ofSize: 14)
        currencyLabel.textColor = .white

        valueLabel.font = .systemFont(ofSize: 16, weight: .regular)
        valueLabel.textColor = .white

        changeLabel.font = .systemFont(ofSize: 12)

        let mainStack = UIStackView(arrangedSubviews: [flagLabel, currencyLabel, valueLabel, changeLabel])
        mainStack.axis = .vertical
        mainStack.alignment = .center
        mainStack.spacing = 4

        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with rate: Rate) {
        flagLabel.text = rate.flag
        currencyLabel.text = rate.currency
        valueLabel.text = PriceFormatter.byn(rate.value, fractionDigits: 3)

        changeLabel.text = String(format: "%+.2f%%", rate.change)
        changeLabel.textColor =
            rate.change > 0 ? .systemGreen :
            rate.change < 0 ? .systemRed :
            UIColor.white.withAlphaComponent(0.6)
    }
}
