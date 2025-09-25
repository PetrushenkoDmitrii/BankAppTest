import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .appThemeDidChange, object: nil)
        applyTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyTheme()
    }

    private func setupTabs() {
        let main = UINavigationController(rootViewController: MainViewController())
        main.tabBarItem = UITabBarItem(title: "Главная", image: UIImage(systemName: "house.fill"), tag: 0)

        let map = UINavigationController(rootViewController: MapViewController())
        map.tabBarItem = UITabBarItem(title: "Карта", image: UIImage(systemName: "map.fill"), tag: 1)

        let rates = UINavigationController(rootViewController: RatesViewController())
        rates.tabBarItem = UITabBarItem(title: "Курсы валют", image: UIImage(systemName: "chart.line.uptrend.xyaxis"), tag: 2)

        let conv = UINavigationController(rootViewController: ConverterViewController())
        conv.tabBarItem = UITabBarItem(title: "Конвертер", image: UIImage(systemName: "arrow.left.arrow.right"), tag: 3)

        let settings = UINavigationController(rootViewController: SettingsViewController())
        settings.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gearshape.fill"), tag: 4)

        viewControllers = [main, map, rates, conv, settings]
    }

    @objc private func applyTheme() {
        guard tabBar.bounds.width > 0, tabBar.bounds.height > 0 else { return }
        let p = AppThemeManager.shared.palette

        let a = UITabBarAppearance()
        a.configureWithTransparentBackground()
        a.backgroundEffect = nil
        a.backgroundColor = .clear
        a.backgroundImage = gradientImage(size: tabBar.bounds.size, colors: p.gradient)
        a.shadowColor = .clear

        a.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: p.textSecondary]
        a.inlineLayoutAppearance.normal.titleTextAttributes  = [.foregroundColor: p.textSecondary]
        a.compactInlineLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: p.textSecondary]

        tabBar.standardAppearance = a
        tabBar.scrollEdgeAppearance = a
        tabBar.isTranslucent = false
        tabBar.tintColor = p.accent                     
        tabBar.unselectedItemTintColor = p.textSecondary
    }

    private func gradientImage(size: CGSize, colors: [UIColor]) -> UIImage? {
        let layer = CAGradientLayer()
        layer.frame = CGRect(origin: .zero, size: size)
        layer.colors = colors.map { $0.cgColor }
        layer.startPoint = CGPoint(x: 0.2, y: 0)
        layer.endPoint   = CGPoint(x: 0.8, y: 1)
        layer.locations  = [0, 0.5, 1]
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in layer.render(in: ctx.cgContext) }
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}
