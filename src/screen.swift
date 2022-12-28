import SwiftUI
import MetalKit

internal let screen = Screen(screenWidth, screenHeight)
internal let clear = Screen(screenWidth, screenHeight)
private let scale = density

class Screen {
    let data: UnsafeMutablePointer<ARGB>!
    let texture: MTLTexture!
    let width: Int
    let height: Int
    let line: Int
    let count: Int
    var shouldClear: Bool = false

    init(_ w: Int, _ h: Int) {
        width = Int(CGFloat(w) * scale)
        height = Int(CGFloat(h) * scale)

        let descriptor = MTLTextureDescriptor()

        descriptor.width = width
        descriptor.height = height
        descriptor.usage = .shaderRead
        descriptor.storageMode = .shared
        descriptor.pixelFormat = .bgra8Unorm
        line = width*4

        let buffer = device.makeBuffer(length: line * height)!

        texture = buffer.makeTexture(descriptor: descriptor, offset: 0, bytesPerRow: line)!
        data = buffer.contents().assumingMemoryBound(to: ARGB.self)
        count = buffer.length/4
        clear()
    }

    func clear() {
        for i in 0..<count {
            data[i] = backgroundColor
        }
    }
}

extension Numeric where Self: Comparable {
    func clamp(_ minimum: Self, _ maximum: Self) -> Self {
        return Swift.min(Swift.max(minimum, self), maximum)
    }
}

extension Int {
    func scaled(_ scale: CGFloat = scale) -> Int {
        Int(CGFloat(self) * scale)
    }
}

private func mix(_ A: ARGB, to B: inout ARGB) {
    let (Aa, Ar, Ag, Ab) = (Float(A.a), Float(A.r), Float(A.g), Float(A.b))
    let (Ba, Br, Bg, Bb) = (Float(B.a), Float(B.r), Float(B.g), Float(B.b))
    let opacity = Aa / 255
    let transparency = 1 - opacity
    let Ba_transparency = Ba * transparency
    let a = ( Aa + Ba_transparency ).clamp(0, 255)

    B.a = ARGB(a)
    B.r = ARGB(( (Ar*Aa + Br*Ba_transparency)/a ).clamp(0, 255))
    B.g = ARGB(( (Ag*Aa + Bg*Ba_transparency)/a ).clamp(0, 255))
    B.b = ARGB(( (Ab*Aa + Bb*Ba_transparency)/a ).clamp(0, 255))
}

internal func _plot(_ x: Int, _ y: Int, with color: ARGB) {
    guard valid(x, y) else { return }
    let index = x + y*screen.line/4

    mix(color, to: &screen.data[index])
}

internal func _plot(_ _x: CGFloat, _ _y: CGFloat, with color: ARGB) {
    let x = Int(_x), y = Int(_y)
    guard valid(x, y) else { return }
    let index = x + y*screen.line/4

    mix(color, to: &screen.data[index])
}

@inlinable
public func valid(_ x: Int, _ y: Int) -> Bool {
    return (x >= 0) && (y >= 0) && (x < scaledScreenWidth) && (y < scaledScreenHeight)
}

public let scaledScreenWidth = screenWidth.scaled()
public let scaledScreenHeight = screenHeight.scaled()

public func plot(_ _x: Int, _ _y: Int, with color: ARGB) {
    let x = _x.scaled()
    let y = _y.scaled()

    _plot(x, y, with: color)
}

private var lastPlotted: NSPoint!
internal var connectNext = false

public func plot(_ _point: NSPoint, with color: ARGB) {
    var point = _point
    let x = Int(point.x * scale)
    let y = scaledScreenHeight - Int(point.y * scale)

    point.x = CGFloat(x)
    point.y = CGFloat(y)
    if connectNext {
        line(from: lastPlotted, to: point, with: color)
    } else {
        _plot(x, y, with: color)
    }
    lastPlotted = point
}
