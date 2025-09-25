import UIKit


var onSelectBase:  (() -> Void)?
var onSelectQuote: (() -> Void)?

enableTap(on: baseChip,  action: #selector(didTapBase))
enableTap(on: quoteChip, action: #selector(didTapQuote))

@objc private func didTapBase()  { onSelectBase?() }
@objc private func didTapQuote() { onSelectQuote?() }

private func enableTap(on view: UIView, action: Selector) {
    view.isUserInteractionEnabled = true
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
}
