import UIKit

final class MainView: UIView {

    let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    let balanceView = BalanceView()
    let ratesView = RatesHorizontalView()
    let converterPreview: ConverterPreviewView
    let mapCardView = MapCardView()

    private let byn = Currency(code: "BYN", name: "Белорусский рубль", symbol: "Br", flag: "🇧🇾")
    private let usd = Currency(code: "USD", name: "Доллар США", symbol: "$", flag: "🇺🇸")

    override init(frame: CGRect) {
        let rate = ExchangeRate(base: byn, quote: usd, rate: 1, updatedAt: Date())
        converterPreview = ConverterPreviewView(model: ConverterPreviewModel(amountBase: 0, rate: rate))
        super.init(frame: frame)
        setupLayout()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        scrollView.addSubview(contentStack)
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32)
        ])

        contentStack.addArrangedSubview(balanceView)
        contentStack.addArrangedSubview(ratesView)
        contentStack.addArrangedSubview(converterPreview)
        contentStack.addArrangedSubview(mapCardView)
    }
}
