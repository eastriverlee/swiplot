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

internal func add(_ color: ARGB, to original: inout ARGB) {
    let color_r = color.r * color.a / 255
    let color_g = color.g * color.a / 255
    let color_b = color.b * color.a / 255

    original.r = (original.r + color_r).clamp(0, 255)
    original.g = (original.g + color_g).clamp(0, 255)
    original.b = (original.b + color_b).clamp(0, 255)
}

private func plot(absolute x: Int, absolute y: Int, with color: ARGB) {
    let index = x + y*screen.line/4

    add(color, to: &screen.data[index])
}

private let scaledScreenWidth = screenWidth.scaled()
private let scaledScreenHeight = screenHeight.scaled()

internal func plot(_ x: Int, _ y: Int, with color: ARGB) {
    let x = x.scaled().clamp(0, screenWidth - 1)
    let y = y.scaled().clamp(0, screenHeight - 1)

    plot(absolute: x, absolute: y, with: color)
}

internal func plot(_ point: NSPoint, with color: ARGB) {
    var x = Int(point.x * scale)
    var y = scaledScreenHeight - Int(point.y * scale)
    x = x.clamp(0, scaledScreenWidth - 1)
    y = y.clamp(0, scaledScreenHeight - 1)

    plot(absolute: x, absolute: y, with: color)
}
