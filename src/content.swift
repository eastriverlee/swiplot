import SwiftUI
import MetalKit

var screenWidth = 481
var screenHeight = 481

struct Window: View {
    var body: some View {
        MetalView()
            .frame(width: CGFloat(screenWidth), height: CGFloat(screenHeight))
            .onAppear { run() }
    }
}

func run() {
    gradation()
    plot(240, 240, with: 0xFFFFFF)
}

func gradation() {
    let r: UInt32 = 0x880000
    var g: UInt32 = 0x000000
    var b: UInt32 = 0x000000
    for y in 0..<screenHeight {
        g = UInt32(Float(0xFF) * Float(y)/Float(screenHeight)) << 8
            for x in 0..<screenWidth {
                b = UInt32(Float(0xFF) * Float(x)/Float(screenWidth))
                    plot(x, y, with: r+g+b)
            }
    }

}

struct Content: View { 
    var body: some View {
        Window()
    }
}
