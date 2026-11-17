import SwiftUI
import UIKit

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

    func withAlpha(_ newAlpha: Double) -> CodableColor {
        CodableColor(red: red, green: green, blue: blue, alpha: newAlpha)
    }

    func shiftedHue(to hue: Double, saturation: Double = 0.55, brightness: Double = 0.94) -> CodableColor {
        let adjusted = UIColor(
            hue: min(max(hue, 0.0), 1.0),
            saturation: min(max(saturation, 0.15), 0.95),
            brightness: min(max(brightness, 0.40), 1.0),
            alpha: alpha
        )
        var r: CGFloat = 0
        var g: CGFloat = 0
        var bl: CGFloat = 0
        var al: CGFloat = 0
        adjusted.getRed(&r, green: &g, blue: &bl, alpha: &al)
        return CodableColor(red: Double(r), green: Double(g), blue: Double(bl), alpha: Double(al))
    }

    var hueComponent: Double {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Double(h)
    }
}

enum PastelPalette {
    // Exact ADR AppColors palette
    static let mintGreen = CodableColor(hex: 0x72D8B0)
    static let mintDark = CodableColor(hex: 0x38A179)
    static let mintLight = CodableColor(hex: 0xD4F8E8)

    static let butterYellow = CodableColor(hex: 0xFFE066)
    static let butterDark = CodableColor(hex: 0xE5B51E)
    static let butterWarm = CodableColor(hex: 0xFFF2A8)

    static let lavenderPurple = CodableColor(hex: 0xC7B1E8)
    static let lavenderDark = CodableColor(hex: 0x8E6CC7)
    static let lavenderLight = CodableColor(hex: 0xF1E9FC)

    static let peachSoft = CodableColor(hex: 0xFFB088)
    static let peachDark = CodableColor(hex: 0xE87545)
    static let peachLight = CodableColor(hex: 0xFFE3D6)

    static let skyBlue = CodableColor(hex: 0x78C8F0)
    static let skyDark = CodableColor(hex: 0x3A98D0)
    static let skyLight = CodableColor(hex: 0xD8F1FD)

    static let roseSoft = CodableColor(hex: 0xFF8DA1)
    static let roseDark = CodableColor(hex: 0xDE4562)
    static let roseLight = CodableColor(hex: 0xFFE0E6)

    // Room surfaces & text
    static let roomBathBg = CodableColor(hex: 0xD9F2FD)
    static let roomBakeBg = CodableColor(hex: 0xFFF5D6)
    static let roomGardenBg = CodableColor(hex: 0xD8F5E5)
    static let roomStudioBg = CodableColor(hex: 0xF3EBFC)
    static let roomWardrobeBg = CodableColor(hex: 0xFFEEF3)

    static let cloudWhite = CodableColor(hex: 0xFFFDF8)
    static let cloudBackground = CodableColor(hex: 0xF3EBFC)
    static let textDark = CodableColor(hex: 0x2D3748)
    static let textMuted = CodableColor(hex: 0x5A6679)
    static let strokeSoft = CodableColor(hex: 0x6B7A99)
    static let cardBorder = CodableColor(hex: 0xD6E3F5)

    // Backwards-friendly aliases
    static let mint = mintGreen
    static let mintDeep = mintDark
    static let butterGold = butterDark
    static let lavender = lavenderPurple
    static let lavenderDeep = lavenderDark
    static let skyTop = CodableColor(hex: 0xE0F2FE)
    static let skyMid = CodableColor(hex: 0xEDE7F6)
    static let skyBottom = CodableColor(hex: 0xFEF3C7)
    static let peach = peachSoft
    static let coralBlush = roseSoft
    static let inkText = textDark
    static let mutedText = textMuted
    static let cardSurface = CodableColor(hex: 0xFFFFFF, alpha: 0.94)

    // Exact 14 ADR Kid Swatches
    static let kidSwatches: [CodableColor] = [
        CodableColor(hex: 0xFF5E7E), // Strawberry pink
        CodableColor(hex: 0xFF9F43), // Honey orange
        CodableColor(hex: 0xFFDD59), // Sunny lemon
        CodableColor(hex: 0x2ED573), // Fresh apple green
        CodableColor(hex: 0x1DD1A1), // Jade mint
        CodableColor(hex: 0x48DBFB), // Sky cyan
        CodableColor(hex: 0x54A0FF), // Candy blue
        CodableColor(hex: 0x9980FA), // Lavender indigo
        CodableColor(hex: 0xED4C67), // Ruby berry
        CodableColor(hex: 0xFDA7DF), // Cotton candy pink
        CodableColor(hex: 0xFFC312), // Royal gold
        CodableColor(hex: 0xC4E538), // Lime sprout
        CodableColor(hex: 0x12CBC4), // Teal breeze
        CodableColor(hex: 0xD980FA)  // Lilac blossom
    ]
}
