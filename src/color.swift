import SwiftUI
import MetalKit

extension Color {
    var hex: String {"\(self.description.suffix(8).prefix(6))"}
    init(hex: String) {
        let scanner = Scanner(string: hex)
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
        let scanner = Scanner(string: self.hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xff0000) >> 16)
        let g = CGFloat((rgb & 0x00ff00) >> 8)
        let b = CGFloat((rgb & 0x0000ff) )
        return (r, g, b)
    }
    func rgba() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let scanner = Scanner(string: "\(self.description.suffix(8))")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xff000000) >> 24)
        let g = CGFloat((rgb & 0x00ff0000) >> 16)
        let b = CGFloat((rgb & 0x0000ff00) >> 8)
        let a = CGFloat((rgb & 0x000000ff) )
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
