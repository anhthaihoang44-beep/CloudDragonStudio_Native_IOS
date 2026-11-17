import SwiftUI

struct CodableColor: Codable, Equatable, Hashable, Sendable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = min(max(red, 0.0), 1.0)
        self.green = min(max(green, 0.0), 1.0)
        self.blue = min(max(blue, 0.0), 1.0)
        self.alpha = min(max(alpha, 0.0), 1.0)
    }

    init(hex: UInt32, alpha: Double = 1.0) {
        self.red = Double((hex >> 16) & 0xFF) / 255.0
        self.green = Double((hex >> 8) & 0xFF) / 255.0
        self.blue = Double(hex & 0xFF) / 255.0
        self.alpha = alpha
    }

    var swiftUIColor: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }

    var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    func shiftedHue(to hue: Double, saturationBoost: Double = 0.0) -> CodableColor {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        let targetSat = min(max(Double(s) + saturationBoost, 0.25), 0.95)
        let targetBri = max(Double(b), 0.72)
        let adjusted = UIColor(
            hue: min(max(hue, 0.0), 1.0),
            saturation: targetSat,
            brightness: targetBri,
            alpha: a
        )
        var r: CGFloat = 0
        var g: CGFloat = 0
        var bl: CGFloat = 0
        var al: CGFloat = 0
        adjusted.getRed(&r, green: &g, blue: &bl, alpha: &al)
        return CodableColor(red: Double(r), green: Double(g), blue: Double(bl), alpha: Double(al))
    }
}

enum PastelPalette {
    // Primary brand palette: mint, butter yellow, lavender
    static let mint = CodableColor(hex: 0x9EEAD0)
    static let mintDeep = CodableColor(hex: 0x5CC9A7)
    static let butterYellow = CodableColor(hex: 0xFFF3B0)
    static let butterGold = CodableColor(hex: 0xFFDA77)
    static let lavender = CodableColor(hex: 0xD8C7FF)
    static let lavenderDeep = CodableColor(hex: 0x9F84EA)

    // Supporting cloud-town pastels
    static let skyTop = CodableColor(hex: 0xDCF3FF)
    static let skyMid = CodableColor(hex: 0xEDE5FF)
    static let skyBottom = CodableColor(hex: 0xFFF7DC)
    static let peach = CodableColor(hex: 0xFFD8BE)
    static let coralBlush = CodableColor(hex: 0xFF9EB5)
    static let berryPlum = CodableColor(hex: 0x5C4D7D)
    static let inkText = CodableColor(hex: 0x35324E)
    static let mutedText = CodableColor(hex: 0x625E80)
    static let cardSurface = CodableColor(hex: 0xFFFFFF, alpha: 0.92)

    static let studioSwatches: [CodableColor] = [
        mint,
        butterYellow,
        lavender,
        peach,
        coralBlush,
        CodableColor(hex: 0xA2D8FF),
        CodableColor(hex: 0xB8F2B6),
        CodableColor(hex: 0xFFC8E2),
        CodableColor(hex: 0xFFE29A),
        CodableColor(hex: 0xC6E5FF),
        CodableColor(hex: 0xE7C6FF),
        CodableColor(hex: 0xFFFDF7)
    ]
}
