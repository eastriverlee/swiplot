import SwiftUI

public var _line: (NSPoint, NSPoint, ARGB)->() = softLine

private extension CGFloat {
    var integer: CGFloat { CGFloat(floorf(Float(self))) }
    var fraction: CGFloat { self - integer }
    var rfraction: CGFloat { 1 - (self - integer) }
}

@inlinable
public func line(from start: NSPoint, to end: NSPoint, with color: ARGB) {
    _line(start, end, color)
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

internal func softLine(from start: NSPoint, to end: NSPoint, with color: ARGB) {
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

internal func hardLine(from start: NSPoint, to end: NSPoint, with color: ARGB) {
   var x = (Int(start.x), Int(end.x))
   var y = (Int(start.y), Int(end.y))

   let dx =  abs(x.1-x.0), sx = x.0 < x.1 ? 1 : -1
   let dy = -abs(y.1-y.0), sy = y.0 < y.1 ? 1 : -1
   var error = dx+dy

   while true {
       let _x = x.0
       let _y = y.0
       let e2 = 2*error

       _plot(_x, _y, with: color)
       if x.0 == x.1 && y.0 == y.1 { break }
       if e2 >= dy { error += dy; x.0 += sx }
       if e2 <= dx { error += dx; y.0 += sy }
   }
}

internal func thickHardLine(from start: NSPoint, to end: NSPoint, with color: ARGB) {
   var x = (Int(start.x), Int(end.x))
   var y = (Int(start.y), Int(end.y))

   let dx = abs(x.1-x.0), sx = x.0 < x.1 ? 1 : -1
   let dy = abs(y.1-y.0), sy = y.0 < y.1 ? 1 : -1
   var error = dx-dy

   while true {
       let _x = x.0
       let _y = y.0
       let e2 = 2*error

       _plot(_x, _y, with: color)

       if e2 >= -dx {
           if x.0 == x.1 { break }
           _plot(_x, _y+sy, with: color)
           error -= dy; x.0 += sx
       }

       if e2 <= dy {
           if y.0 == y.1 { break }
           _plot(_x+sx, _y, with: color)
           error += dx; y.0 += sy
       }
   }
}
