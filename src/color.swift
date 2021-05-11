import SwiftUI
import MetalKit

extension Color {
    var hex: String {
        let description = self.description
        if description.hasPrefix("#") {
            return "\(description.suffix(8))"
        } else {
            switch description {
                case "white": return "FFFFFFFF"
                case "black": return "000000FF"
                case "red": return "FF443AFF"
                case "green": return "32D74BFF"
                case "blue": return "0A84FFFF"
                case "orange": return "FF9F0AFF"
                case "yellow": return "FFD60AFF"
                case "pink": return "FC375DFF"
                case "purple": return "8E41B5FF"
                case "gray": return "98989DFF"
                case "primary": return "E3E3E3FF"
                case "secondary": return "A3A3A3FF"
                default: return "00000000"
            }
        }
    }
    init(hex: String) {
        let scanner = Scanner(string: hex.uppercased())
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb & 0xff0000) >> 16) / 255
        let g = Double((rgb & 0x00ff00) >> 8) / 255
        let b = Double((rgb & 0x0000ff)) / 255
        self.init(red: r, green: g, blue: b)
    }
    init(hex: String, alpha: CGFloat) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb & 0xff0000) >> 16) / 255
        let g = Double((rgb & 0x00ff00) >> 8) / 255
        let b = Double((rgb & 0x0000ff)) / 255
        self.init(NSColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: alpha))
    }
    func rgb() -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        let scanner = Scanner(string: "\(hex.prefix(6))")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xff0000) >> 16)
        let g = CGFloat((rgb & 0x00ff00) >> 8)
        let b = CGFloat((rgb & 0x0000ff) )
        return (r, g, b)
    }
    func rgba() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let scanner = Scanner(string: hex)
        var rgba: UInt64 = 0
        scanner.scanHexInt64(&rgba)
        let r = CGFloat((rgba & 0xff000000) >> 24)
        let g = CGFloat((rgba & 0x00ff0000) >> 16)
        let b = CGFloat((rgba & 0x0000ff00) >> 8)
        let a = CGFloat((rgba & 0x000000ff) )
        return (r, g, b, a)
    }
    var metal: MTLClearColor {
        let rgba = self.rgba()
        let r = Double(rgba.r / 255)
        let g = Double(rgba.g / 255)
        let b = Double(rgba.b / 255)
        let a = Double(rgba.a / 255)
        return MTLClearColor(red: r, green: g, blue: b, alpha: a)
    }
}
