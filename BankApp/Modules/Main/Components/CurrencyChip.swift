import UIKit

final class CurrencyChip: UIView {
    private let iconView = UIImageView()
    private let codeLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white.withAlphaComponent(0.15)
        layer.cornerRadius = 12

        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.setContentCompressionResistancePriority(.required, for: .horizontal)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 28).isActive = true

        codeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        codeLabel.textColor = .white

        let h = UIStackView(arrangedSubviews: [iconView, codeLabel])
        h.axis = .horizontal
        h.spacing = 6
        h.alignment = .center

        addSubview(h)
        h.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            h.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            h.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            h.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            h.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ c: Currency) {
        codeLabel.text = c.code
        if CryptoIcon.isKnown(c.code) {
            iconView.image = CryptoIcon.image(for: c.code, diameter: 28)
        } else {
            iconView.image = FlagIcon.image(emoji: c.flag, diameter: 28)
        }
    }
}
