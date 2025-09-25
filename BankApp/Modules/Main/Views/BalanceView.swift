import UIKit

final class BalanceView: UIView {

    // MARK: UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Общий баланс"
        l.font = .systemFont(ofSize: 16, weight: .medium)
        l.textColor = .white
        return l
    }()

    private let amountLabel: UILabel = {
        let l = UILabel()
        l.text = "00.00р"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = .white
        return l
    }()

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.cornerRadius = 16
        clipsToBounds = true

        let stack = UIStackView(arrangedSubviews: [titleLabel, amountLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: API
    func setAmount(_ text: String) { amountLabel.text = text }
}
