import UIKit
public enum CryptoIcon {

    public static func image(for code: String,
                             diameter: CGFloat,
                             scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let style = styles[code.uppercased()] ?? fallbackStyle
        let size = CGSize(width: diameter, height: diameter)

        let fmt = UIGraphicsImageRendererFormat()
        fmt.scale = scale
        fmt.opaque = false

        return UIGraphicsImageRenderer(size: size, format: fmt).image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: diameter / 2)

            if let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                     colors: [style.start.cgColor, style.end.cgColor] as CFArray,
                                     locations: [0, 1]) {
                ctx.cgContext.addPath(path.cgPath)
                ctx.cgContext.clip()
                ctx.cgContext.drawLinearGradient(
                    grad,
                    start: CGPoint(x: 0, y: 0),
                    end:   CGPoint(x: diameter, y: diameter),
                    options: []
                )
            } else {
                style.start.setFill()
                path.fill()
            }

            UIColor.white.withAlphaComponent(0.18).setStroke()
            path.lineWidth = 1
            path.stroke()

            let s = style.glyph as NSString
            let font = UIFont.systemFont(ofSize: diameter * 0.5, weight: .bold)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white
            ]
            let gSize = s.size(withAttributes: attrs)
            let gRect = CGRect(
                x: (diameter - gSize.width)  / 2,
                y: (diameter - gSize.height) / 2,
                width: gSize.width, height: gSize.height
            )
            s.draw(in: gRect, withAttributes: attrs)
        }
    }

    public static func isKnown(_ code: String) -> Bool {
        styles.keys.contains(code.uppercased())
    }

    private struct Style { let glyph: String; let start: UIColor; let end: UIColor }

    private static let styles: [String: Style] = [
        "BTC": .init(glyph: "₿",
                     start: UIColor(red: 0.98, green: 0.58, blue: 0.10, alpha: 1.0),
                     end:   UIColor(red: 0.76, green: 0.40, blue: 0.06, alpha: 1.0)),
        "ETH": .init(glyph: "Ξ",
                     start: UIColor(red: 0.53, green: 0.46, blue: 0.88, alpha: 1.0),
                     end:   UIColor(red: 0.34, green: 0.27, blue: 0.63, alpha: 1.0)),
        "USDT": .init(glyph: "₮",
                      start: UIColor(red: 0.00, green: 0.65, blue: 0.53, alpha: 1.0),
                      end:   UIColor(red: 0.00, green: 0.47, blue: 0.39, alpha: 1.0)),
        "BNB": .init(glyph: "B",
                     start: UIColor(red: 1.00, green: 0.84, blue: 0.00, alpha: 1.0),
                     end:   UIColor(red: 0.88, green: 0.66, blue: 0.00, alpha: 1.0)),
        "XRP": .init(glyph: "✕",
                     start: UIColor(white: 0.30, alpha: 1.0),
                     end:   UIColor(white: 0.10, alpha: 1.0)),
        "ADA": .init(glyph: "A",
                     start: UIColor(red: 0.16, green: 0.49, blue: 0.96, alpha: 1.0),
                     end:   UIColor(red: 0.02, green: 0.24, blue: 0.62, alpha: 1.0)),
        "DOGE": .init(glyph: "Ð",
                      start: UIColor(red: 0.91, green: 0.77, blue: 0.20, alpha: 1.0),
                      end:   UIColor(red: 0.70, green: 0.58, blue: 0.12, alpha: 1.0)),
        "SOL": .init(glyph: "◎",
                     start: UIColor(red: 0.43, green: 0.94, blue: 0.78, alpha: 1.0),
                     end:   UIColor(red: 0.64, green: 0.43, blue: 0.97, alpha: 1.0)),
        "TRX": .init(glyph: "T",
                     start: UIColor(red: 0.94, green: 0.20, blue: 0.25, alpha: 1.0),
                     end:   UIColor(red: 0.70, green: 0.05, blue: 0.12, alpha: 1.0)),
        "DOT": .init(glyph: "•",
                     start: UIColor(red: 0.98, green: 0.17, blue: 0.49, alpha: 1.0),
                     end:   UIColor(red: 0.64, green: 0.00, blue: 0.28, alpha: 1.0)),
    ]

    private static let fallbackStyle = Style(
        glyph: "•",
        start: UIColor(white: 0.35, alpha: 1.0),
        end:   UIColor(white: 0.12, alpha: 1.0)
    )
}

public enum FlagIcon {
    public static func image(emoji: String,
                             diameter: CGFloat,
                             scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let size = CGSize(width: diameter, height: diameter)
        let fmt = UIGraphicsImageRendererFormat()
        fmt.scale = scale
        fmt.opaque = false

        return UIGraphicsImageRenderer(size: size, format: fmt).image { _ in
            let font = UIFont.systemFont(ofSize: diameter * 0.82)
            let attr = NSAttributedString(string: emoji, attributes: [.font: font])
            let s = attr.size()
            let rect = CGRect(x: (size.width  - s.width)  / 2,
                              y: (size.height - s.height) / 2,
                              width: s.width, height: s.height)
            attr.draw(in: rect)
        }
    }
}
