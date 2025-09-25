import UIKit

final class SettingsViewController: BaseViewController {

    private let card = UIView()
    private let stack = UIStackView()
    private let themeLabel = UILabel()
    private let themeControl = UISegmentedControl(items: ["Тёмная", "Светлая"])
    private let divider = UIView()
    private let versionLeft = UILabel()
    private let versionRight = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Настройки"

        stack.axis = .vertical
        stack.spacing = 0

        themeLabel.text = "Тема"
        themeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        themeControl.selectedSegmentIndex = AppThemeManager.shared.theme == .dark ? 0 : 1
        themeControl.addTarget(self, action: #selector(onThemeChanged), for: .valueChanged)

        versionLeft.text = "Версия"
        versionRight.textAlignment = .right
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        versionRight.text = "\(v) (\(b))"

        let row1 = row(themeLabel, right: themeControl)
        let row2 = row(versionLeft, right: versionRight)

        view.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 16

        card.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(row1)
        stack.addArrangedSubview(divider)
        stack.addArrangedSubview(row2)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            stack.topAnchor.constraint(equalTo: card.topAnchor),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor),

            divider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        ])

        applyPalette()
        NotificationCenter.default.addObserver(self, selector: #selector(applyPalette), name: .appThemeDidChange, object: nil)
    }

    @objc private func onThemeChanged() {
        AppThemeManager.shared.theme = themeControl.selectedSegmentIndex == 0 ? .dark : .light
    }

    @objc private func applyPalette() {
        let p = AppThemeManager.shared.palette
        card.backgroundColor = p.card
        themeLabel.textColor = .white                // ← весь текст в настройках белый
        versionLeft.textColor = .white
        versionRight.textColor = p.textSecondary

        divider.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        themeControl.selectedSegmentTintColor = p.accent
        themeControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        themeControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
    }

    private func row(_ left: UIView, right: UIView) -> UIView {
        let v = UIView()
        let h = UIStackView(arrangedSubviews: [left, right])
        h.axis = .horizontal
        h.alignment = .center
        h.spacing = 12
        v.addSubview(h)
        h.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            h.topAnchor.constraint(equalTo: v.topAnchor, constant: 14),
            h.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -14),
            h.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 16),
            h.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -16)
        ])
        return v
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}
