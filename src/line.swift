import SwiftUI

public var _line: (NSPoint, NSPoint, ARGB)->() = line

private extension CGFloat {
    var integer: CGFloat { CGFloat(floorf(Float(self))) }
    var fraction: CGFloat { self - integer }
    var rfraction: CGFloat { 1 - (self - integer) }
}

public func line(from start: NSPoint, to end: NSPoint, with color: ARGB) {
    var x = (start.x, end.x, start.x)
    var y = (start.y, end.y)
    
    let dx: CGFloat = abs(x.1-x.0), sx: CGFloat = x.0 < x.1 ? 1 : -1
    let dy: CGFloat = abs(y.1-y.0), sy: CGFloat = y.0 < y.1 ? 1 : -1
    var error = dx-dy
    var e2: CGFloat
    let ed: CGFloat = dx+dy==0 ? 1 : sqrt(dx*dx + dy*dy)
    
    while true {
        _plot(x.0, y.0, with: color.transparent(abs(error-dx+dy)/ed))
        e2 = error; x.2 = x.0
        if 2*e2 >= -dx {
            if x.0 == x.1 { break }
            if e2+dy < ed { _plot(x.0, y.0+sy, with: color.transparent((e2+dy)/ed)) }
            error -= dy; x.0 += sx
        }
        if 2*e2 <= dy {
            if y.0 == y.1 { break }
            if dx-e2 < ed { _plot(x.2+sx, y.0, with: color.transparent((dx-e2)/ed)) }
            error += dx; y.0 += sy
        }
    }
}

