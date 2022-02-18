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

private func mix(_ A: ARGB, to B: inout ARGB) {
    let (Aa, Ar, Ag, Ab) = (Float(A.a), Float(A.r), Float(A.g), Float(A.b))
    let (Ba, Br, Bg, Bb) = (Float(B.a), Float(B.r), Float(B.g), Float(B.b))
    let opacity = Aa / 255
    let alpha = 1 - opacity
    let Ba_alpha = Ba * alpha
    let a = ( Aa + Ba_alpha ).clamp(0, 255)

    B.a = ARGB(a)
    B.r = ARGB(( (Ar*Aa + Br*Ba_alpha)/a ).clamp(0, 255))
    B.g = ARGB(( (Ag*Aa + Bg*Ba_alpha)/a ).clamp(0, 255))
    B.b = ARGB(( (Ab*Aa + Bb*Ba_alpha)/a ).clamp(0, 255))
}

private func _plot(_ x: Int, _ y: Int, with color: ARGB) {
    let index = x + y*screen.line/4

    mix(color, to: &screen.data[index])
}

private func _plot(_ x: CGFloat, _ y: CGFloat, with color: ARGB) {
    _plot(Int(x), Int(y), with: color)
}

extension CGFloat {
    var integer: CGFloat { CGFloat(floorf(Float(self))) }
    var fraction: CGFloat { self - integer }
    var rfraction: CGFloat { 1 - (self - integer) }
}

private func plotEndpoint(_ _x: CGFloat, _ _y: CGFloat, with color: ARGB, _ gradient: CGFloat, _ steep: Bool) -> (Int, CGFloat) {
    let x = _x.rounded()
    let y = _y + gradient*(x-_x)
    let yInteger = y.integer
    let gapX = (_x + 0.5).fraction

    if steep {
        _plot(yInteger,   x, with: color.opacity(y.rfraction * gapX))
        _plot(yInteger+1, x, with: color.opacity( y.fraction * gapX))
    } else {
        _plot(x, yInteger,   with: color.opacity(y.rfraction * gapX))
        _plot(x, yInteger+1, with: color.opacity( y.fraction * gapX))
    }
    return (Int(x), y)
}

private func range(from start: Int, to end: Int) -> Range<Int> {
    return start <= end ? start..<end : end..<start
}

internal func line(from start: NSPoint, to end: NSPoint, with color: ARGB) {
    var startX = start.x
    var startY = start.y
    var endX = end.x
    var endY = end.y
    let steep = abs(endY - startY) > abs(endX - startX)

    if steep {
        swap(&startX, &startY)
        swap(&endX, &endY)
    }
    if startX > endX {
        swap(&startX, &endX)
        swap(&startY, &endY)
    }
    let dx = endX - startX
    let dy = endY - startY
    let gradient = dx == 0 ? 1 : (dy / dx)

    let (xStart, yStart) = plotEndpoint(startX, startY, with: color, gradient, steep)
    let (xEnd,        _) = plotEndpoint(  endX,   endY, with: color, gradient, steep)
    let xRange = range(from: xStart+1, to: xEnd)
    var midY = yStart + gradient
    if steep {
        for x in xRange {
            _plot(Int(midY.integer),   x, with: color.opacity(midY.rfraction))
            _plot(Int(midY.integer+1), x, with: color.opacity( midY.fraction))
            midY += gradient
        }
    } else {
        for x in xRange {
            _plot(x, Int(midY.integer),   with: color.opacity(midY.rfraction))
            _plot(x, Int(midY.integer+1), with: color.opacity( midY.fraction))
            midY += gradient
        }
    }
}

private let scaledScreenWidth = screenWidth.scaled()
private let scaledScreenHeight = screenHeight.scaled()

internal func plot(_ x: Int, _ y: Int, with color: ARGB) {
    let x = x.clamp(0, screenWidth - 1)
    let y = y.clamp(0, screenHeight - 1)

    _plot(x, y, with: color)
}

private var lastPlotted: NSPoint!
internal var connectNext = false

internal func plot(_ _point: NSPoint, with color: ARGB) {
    var point = _point
    var x = Int(point.x * scale)
    var y = scaledScreenHeight - Int(point.y * scale)
    x = x.clamp(0, scaledScreenWidth - 1)
    y = y.clamp(0, scaledScreenHeight - 1)

    point.x = CGFloat(x)
    point.y = CGFloat(y)
    if connectNext {
        line(from: lastPlotted, to: point, with: color)
    } else {
        _plot(x, y, with: color)
    }
    lastPlotted = point
}
