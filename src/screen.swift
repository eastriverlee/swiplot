import SwiftUI
import MetalKit

internal let scale = Int(NSScreen.main!.backingScaleFactor)
internal let screen = Screen(width: screenWidth, height: screenHeight)

class Screen {
    var texture: MTLTexture
    var data: UnsafeMutablePointer<UInt32>
    var width: Int
    var height: Int
    var line: Int

    var count: Int

    init(width w: Int, height h: Int) {
        let width = w * scale
        let height = h * scale
        line = width * 4
        line = (line + 255) / 256 * 256

        let descriptor = MTLTextureDescriptor()
        self.width = width
        self.height = height
        descriptor.width = width
        descriptor.height = height
        descriptor.usage = .shaderRead
        descriptor.pixelFormat = .bgra8Unorm

        let device = MTLCreateSystemDefaultDevice()!
        let buffer = device.makeBuffer(length: line * height)!
        texture = buffer.makeTexture(descriptor: descriptor, offset: 0, bytesPerRow: line)!
        data = buffer.contents().assumingMemoryBound(to: RGB.self)
        count  = (width-1) + (height-1)*line/4
        clear()
    }
    func clear() {
        for i in 0..<count {
            data[i] = backgroundColor
        }
    }
}

public func plot(_ x_: Int, _ y_: Int, with color: RGB) {
    let x = x_ * scale
    let y = y_ * scale
    var index = 0

    for y in y..<y+scale {
        for x in x..<x+scale {
            index = x + y*screen.line/4
            screen.data[index] = color
        }
    }
}

public func plot(_ point: NSPoint, with color: RGB) {
    let x = Int(point.x)
    let y = screenHeight - Int(point.y)
    plot(x, y, with: color)
}
