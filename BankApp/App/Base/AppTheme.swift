import UIKit

enum AppTheme: Int { case dark = 0, light = 1 }

struct ThemePalette {
    let gradient: [UIColor]
    let card: UIColor
    let textPrimary: UIColor
    let textSecondary: UIColor
    let accent: UIColor
    let statusBarStyle: UIStatusBarStyle
}

final class AppThemeManager {
    static let shared = AppThemeManager()
    private let key = "app_theme_selected"

    var theme: AppTheme {
        get { AppTheme(rawValue: UserDefaults.standard.integer(forKey: key)) ?? .dark }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
            NotificationCenter.default.post(name: .appThemeDidChange, object: nil)
        }
    }

    var palette: ThemePalette {
        switch theme {
        case .dark:
            return ThemePalette(
                gradient: [
                    UIColor(red: 18/255, green: 7/255,  blue: 51/255, alpha: 1),
                    UIColor(red: 34/255, green: 11/255, blue: 74/255, alpha: 1),
                    UIColor(red: 18/255, green: 7/255,  blue: 51/255, alpha: 1)
                ],
                card: UIColor.white.withAlphaComponent(0.12),
                textPrimary: .white,
                textSecondary: UIColor.white.withAlphaComponent(0.7),
                accent: .systemOrange,
                statusBarStyle: .lightContent
            )
        case .light:
            return ThemePalette(
                gradient: [
                    UIColor(red: 110/255, green: 69/255,  blue: 226/255, alpha: 1),
                    UIColor(red: 122/255, green: 92/255,  blue: 230/255, alpha: 1),
                    UIColor(red: 136/255, green: 179/255, blue: 242/255, alpha: 1)
                ],
                card: UIColor.white.withAlphaComponent(0.10),
                textPrimary: .white,                       // ← белый текст в светлой теме
                textSecondary: UIColor.white.withAlphaComponent(0.7),
                accent: .systemOrange,
                statusBarStyle: .darkContent
            )
        }
    }
}

extension Notification.Name { static let appThemeDidChange = Notification.Name("appThemeDidChange") }
