import Foundation

enum PriceFormatter {

    private static let nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.groupingSeparator = " "
        nf.decimalSeparator  = ","
        return nf
    }()

    @inline(__always)
    private static func format(_ value: Double,
                               fractionDigits: Int,
                               suffix: String) -> String {
        guard value > 0 else { return "—" }
        nf.minimumFractionDigits = fractionDigits
        nf.maximumFractionDigits = fractionDigits
        return (nf.string(from: NSNumber(value: value)) ?? "\(value)") + suffix
    }

    static func byn(_ value: Double, fractionDigits: Int = 3) -> String {
        format(value, fractionDigits: fractionDigits, suffix: " Br")
    }

    static func usd(_ value: Double, fractionDigits: Int = 2) -> String {
        format(value, fractionDigits: fractionDigits, suffix: " $")
    }
}
