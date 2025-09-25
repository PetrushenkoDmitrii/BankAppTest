import UIKit

final class IconBadgeView: UIView {

    private let imageView = UIImageView()
    private var lastDiameter: CGFloat = 36

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        layer.cornerRadius = bounds.height / 2
        lastDiameter = min(bounds.width, bounds.height)
    }

    func configureFiat(flag: String) {
        imageView.image = FlagIcon.image(emoji: flag, diameter: lastDiameter)
        backgroundColor = .clear
    }

    func configureCrypto(symbol: String) {
        imageView.image = CryptoIcon.image(for: symbol, diameter: lastDiameter)
        backgroundColor = .clear
    }
}
