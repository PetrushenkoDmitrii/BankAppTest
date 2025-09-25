import UIKit

final class ConverterPreviewView: UIView, UITextFieldDelegate {

    var model: ConverterPreviewModel { didSet { applyModel() } }

    var onSelectBase:  (() -> Void)?
    var onSelectQuote: (() -> Void)?

    private enum EditingSource { case none, base, quote }
    private var editingSource: EditingSource = .none
    private var isUpdating = false 

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Конвертер валют"
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .white
        return l
    }()

    private let inputContainer = card()
    private let amountField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .decimalPad
        tf.textAlignment = .left
        tf.font = .monospacedDigitSystemFont(ofSize: 18, weight: .medium)
        tf.textColor = .white
        tf.attributedPlaceholder = NSAttributedString(
            string: "0.00",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.45)]
        )
        tf.clearButtonMode = .never
        tf.returnKeyType = .done
        return tf
    }()
    private let baseChip = CurrencyChip()

    private let swapButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "arrow.triangle.2.circlepath"), for: .normal)
        b.tintColor = .white
        b.backgroundColor = .orange
        b.layer.cornerRadius = 24
        b.widthAnchor.constraint(equalToConstant: 48).isActive = true
        b.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return b
    }()

    private let resultContainer = card()
    private let resultField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .decimalPad
        tf.textAlignment = .left
        tf.font = .monospacedDigitSystemFont(ofSize: 20, weight: .bold)
        tf.textColor = .systemYellow
        tf.attributedPlaceholder = NSAttributedString(
            string: "0.00",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.45)]
        )
        tf.clearButtonMode = .never
        tf.returnKeyType = .done
        return tf
    }()
    private let quoteChip = CurrencyChip()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Обновлено только что"
        l.font = .systemFont(ofSize: 12)
        l.textColor = UIColor.white.withAlphaComponent(0.65)
        l.textAlignment = .center
        return l
    }()

    init(model: ConverterPreviewModel) {
        self.model = model
        super.init(frame: .zero)
        backgroundColor = UIColor.white.withAlphaComponent(0.10)
        layer.cornerRadius = 16
        setupUI()
        applyModel()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        let vStack = UIStackView(arrangedSubviews: [titleLabel, inputContainer, swapButton, resultContainer, subtitleLabel])
        vStack.axis = .vertical
        vStack.spacing = 16
        vStack.alignment = .fill
        addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])

        inputContainer.addSubview(amountField)
        inputContainer.addSubview(baseChip)
        amountField.translatesAutoresizingMaskIntoConstraints = false
        baseChip.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inputContainer.heightAnchor.constraint(equalToConstant: 56),

            amountField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            amountField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),

            baseChip.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            baseChip.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -12),

            amountField.trailingAnchor.constraint(lessThanOrEqualTo: baseChip.leadingAnchor, constant: -12)
        ])

        resultContainer.addSubview(resultField)
        resultContainer.addSubview(quoteChip)
        resultField.translatesAutoresizingMaskIntoConstraints = false
        quoteChip.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resultContainer.heightAnchor.constraint(equalToConstant: 56),

            resultField.centerYAnchor.constraint(equalTo: resultContainer.centerYAnchor),
            resultField.leadingAnchor.constraint(equalTo: resultContainer.leadingAnchor, constant: 16),

            quoteChip.centerYAnchor.constraint(equalTo: resultContainer.centerYAnchor),
            quoteChip.trailingAnchor.constraint(equalTo: resultContainer.trailingAnchor, constant: -12),

            resultField.trailingAnchor.constraint(lessThanOrEqualTo: quoteChip.leadingAnchor, constant: -12)
        ])

        inputContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(focusBase)))
        resultContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(focusQuote)))

        amountField.delegate = self
        resultField.delegate = self

        amountField.addTarget(self, action: #selector(beginBaseEditing), for: .editingDidBegin)
        resultField.addTarget(self, action: #selector(beginQuoteEditing), for: .editingDidBegin)
        amountField.addTarget(self, action: #selector(endEditingFields), for: .editingDidEnd)
        resultField.addTarget(self, action: #selector(endEditingFields), for: .editingDidEnd)

        amountField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
        resultField.addTarget(self, action: #selector(resultChanged), for: .editingChanged)

        swapButton.addTarget(self, action: #selector(swapCurrencies), for: .touchUpInside)

        baseChip.isUserInteractionEnabled = true
        quoteChip.isUserInteractionEnabled = true
        baseChip.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBaseChip)))
        quoteChip.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapQuoteChip)))
    }

    private func applyModel() {
        baseChip.configure(model.baseCurrency)
        quoteChip.configure(model.quoteCurrency)

        if editingSource != .base {
            crossfade(amountField, to: model.amountBase == 0 ? nil : Formatter.money.string(from: model.amountBase as NSNumber))
        }
        if editingSource != .quote {
            crossfade(resultField, to: Formatter.money.string(from: model.resultQuote as NSNumber))
        }
    }

    private func crossfade(_ field: UITextField, to text: String?) {
        guard field.text != text else { return }
        UIView.transition(with: field, duration: 0.2, options: .transitionCrossDissolve) {
            field.text = text
        }
    }

    @objc private func focusBase()  { amountField.becomeFirstResponder() }
    @objc private func focusQuote() { resultField.becomeFirstResponder() }

    @objc private func didTapBaseChip()  { onSelectBase?() }
    @objc private func didTapQuoteChip() { onSelectQuote?() }

    @objc private func beginBaseEditing()  { editingSource = .base }
    @objc private func beginQuoteEditing() { editingSource = .quote }
    @objc private func endEditingFields() {
        editingSource = .none
        amountField.text = (model.amountBase == 0) ? nil : Formatter.money.string(from: model.amountBase as NSNumber)
        resultField.text = Formatter.money.string(from: model.resultQuote as NSNumber)
    }

    @objc private func amountChanged() {
        guard editingSource == .base, !isUpdating else { return }
        let val = parseDecimal(amountField.text)
        model.amountBase = val
        isUpdating = true
        resultField.text = Formatter.plain.string(from: model.resultQuote as NSNumber)
        isUpdating = false
    }

    @objc private func resultChanged() {
        guard editingSource == .quote, !isUpdating else { return }
        let quoteVal = parseDecimal(resultField.text)
        let rate = model.rate.rate
        let base = rate == 0 ? 0 : (quoteVal / rate)
        model.amountBase = base
        isUpdating = true
        amountField.text = Formatter.plain.string(from: base as NSNumber)
        isUpdating = false
    }

    @objc private func swapCurrencies() {
        let oldBase = model.amountBase
        let oldResult = model.resultQuote
        let oldRate = model.rate

        let invertedRate = ExchangeRate(
            base: oldRate.quote,
            quote: oldRate.base,
            rate: (1 / (oldRate.rate as NSDecimalNumber).doubleValue).decimal,
            updatedAt: oldRate.updatedAt
        )
        model = ConverterPreviewModel(amountBase: oldResult, rate: invertedRate)

        UIView.transition(with: baseChip, duration: 0.2, options: .transitionCrossDissolve) {
            self.baseChip.configure(self.model.baseCurrency)
        }
        UIView.transition(with: quoteChip, duration: 0.2, options: .transitionCrossDissolve) {
            self.quoteChip.configure(self.model.quoteCurrency)
        }
        crossfade(amountField, to: Formatter.money.string(from: oldResult as NSNumber))
        crossfade(resultField, to: Formatter.money.string(from: oldBase as NSNumber))
    }

    private func parseDecimal(_ text: String?) -> Decimal {
        let s = (text ?? "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ",", with: ".")
        return Decimal(string: s) ?? 0
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString str: String) -> Bool {
        if str.isEmpty { return true } // backspace
        let allowed = CharacterSet(charactersIn: "0123456789.,")
        if str.rangeOfCharacter(from: allowed.inverted) != nil { return false }

        let current = textField.text ?? ""
        let newText = (current as NSString).replacingCharacters(in: range, with: str)
        let parts = newText.components(separatedBy: CharacterSet(charactersIn: ".,"))
        if parts.count > 2 { return false }                // только один разделитель
        if let fractional = parts.last, fractional.count > 8 { return false } // до 8 знаков
        return true
    }

    private static func card() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        v.layer.cornerRadius = 16
        return v
    }
}

private extension Double { var decimal: Decimal { Decimal(self) } }

extension Formatter {
    static let money: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = .current
        f.numberStyle = .decimal
        f.usesGroupingSeparator = true
        f.groupingSize = 3
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()

    static let plain: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = .current
        f.numberStyle = .decimal
        f.usesGroupingSeparator = false
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 8
        return f
    }()
}
