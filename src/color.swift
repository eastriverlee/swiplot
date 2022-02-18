import SwiftUI
import MetalKit

typealias RGB = UInt32
typealias RGBA = RGB
typealias ARGB = RGB

extension ARGB { 
    var a: ARGB {
        get {
            return ((self & 0xff000000) >> 24)
        }
        set (color) {
            self &= 0x00ffffff
            self += ((color & 0xff) << 24)
        }
    }
    var r: ARGB {
        get {
            return ((self & 0x00ff0000) >> 16)
        }
        set (color) {
            self &= 0xff00ffff
            self += ((color & 0xff) << 16)
        }
    }
    var g: ARGB {
        get {
            return ((self & 0x0000ff00) >> 8)
        }
        set (color) {
            self &= 0xffff00ff
            self += ((color & 0xff) << 8)
        }
    }
    var b: ARGB {
        get {
            return (self & 0xff)
        }
        set (color) {
            self &= 0xffffff00
            self += (color & 0xff)
        }
    }
    var metal: MTLClearColor {
        return (Color(raw: self).metal)
    }
    func opacity(_ opacity: CGFloat) -> ARGB {
        var clone = self
        clone.a = ARGB(CGFloat(clone.a) * opacity)
        return clone
    }
}

extension Color {
    var hex: String {
        return String(format: "%8x", raw)
    }
    var raw: ARGB {
        let rgba = rgba()

        return ARGB(rgba.a)<<24 + ARGB(rgba.r)<<16 + ARGB(rgba.g)<<8 + ARGB(rgba.b)
        
    }
    init(raw: RGB, alpha: CGFloat = 1) {
        let r = CGFloat(raw.r) / 255
        let g = CGFloat(raw.g) / 255
        let b = CGFloat(raw.b) / 255
        self.init(NSColor(red: r, green: g, blue: b, alpha: alpha))
    }
    func rgb() -> (r: CGFloat, g: CGFloat, b: CGFloat) {
        let color = NSColor(self).cgColor.components!
        let r = color[0] * 255 
        let g = color[1] * 255 
        let b = color[2] * 255 
        return (r, g, b)
    }
    func rgba() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let color = NSColor(self).cgColor.components!
        let r = color[0] * 255 
        let g = color[1] * 255 
        let b = color[2] * 255 
        let a = color[3] * 255 
        return (r, g, b, a)
    }
    var metal: MTLClearColor {
        let rgba = self.rgba()
        let r = Double(rgba.a / 255)
        let g = Double(rgba.r / 255)
        let b = Double(rgba.g / 255)
        let a = Double(rgba.b / 255)
        return MTLClearColor(red: r, green: g, blue: b, alpha: a)
    }
}

