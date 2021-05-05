import SwiftUI
import MetalKit

struct Window: View {
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        MetalView().frame(width: width, height: height)
    }
}

struct Content: View { 
    var body: some View {
        Window(width: 480, height: 480)
    }
}

