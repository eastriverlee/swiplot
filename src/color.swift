import SwiftUI
import MetalKit

typealias RGB = UInt32
typealias RGBA = UInt64

extension RGB { 
    var r: RGB {
        return ((self & 0xff0000) >> 16)
    }
    var g: RGB {
        return ((self & 0x00ff00) >> 8)
    }
    var b: RGB {
        return (self & 0x0000ff)
    }
    var metal: MTLClearColor {
        return (Color(raw: self).metal)
    }
}

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
    var raw: RGB {
        let scanner = Scanner(string: hex.uppercased())
        var rgb: RGBA = 0
        scanner.scanHexInt64(&rgb)
        return RGB(rgb >> 8)
    }
    init(raw: RGB, alpha: CGFloat = 1) {
        let r = CGFloat(raw.r) / 255
        let g = CGFloat(raw.g) / 255
        let b = CGFloat(raw.b) / 255
        self.init(NSColor(red: r, green: g, blue: b, alpha: alpha))
    }
    func rgb() -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        let scanner = Scanner(string: "\(hex.prefix(6))")
        var rgb: RGBA = 0
        scanner.scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xff0000) >> 16)
        let g = CGFloat((rgb & 0x00ff00) >> 8)
        let b = CGFloat((rgb & 0x0000ff) )
        return (r, g, b)
    }
    func rgba() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let scanner = Scanner(string: hex)
        var rgba: RGBA = 0
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

