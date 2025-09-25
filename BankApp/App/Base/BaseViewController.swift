import UIKit

final class GradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    private var grad: CAGradientLayer { layer as! CAGradientLayer }
    func setColors(_ colors: [UIColor]) {
        grad.colors = colors.map { $0.cgColor }
        grad.startPoint = CGPoint(x: 0.2, y: 0)
        grad.endPoint   = CGPoint(x: 0.8, y: 1)
        grad.locations  = [0, 0.5, 1]
    }
}

class BaseViewController: UIViewController {
    private let background = GradientView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.insertSubview(background, at: 0)
        background.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: view.topAnchor),
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .appThemeDidChange, object: nil)
        applyTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
    }

    @objc private func applyTheme() {
        let p = AppThemeManager.shared.palette
        background.setColors(p.gradient)
        view.tintColor = p.accent

        if let nav = navigationController {
            let a = UINavigationBarAppearance()
            a.configureWithTransparentBackground()
            a.titleTextAttributes = [.foregroundColor: UIColor.white]
            a.shadowColor = .clear
            nav.navigationBar.standardAppearance = a
            nav.navigationBar.scrollEdgeAppearance = a
            nav.navigationBar.tintColor = .white                           
        }

        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        AppThemeManager.shared.palette.statusBarStyle
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}
