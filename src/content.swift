import Darwin
import SwiftUI
import MetalKit

internal let screenWidth = CommandLine.argc > 1 ? Int(CommandLine.arguments[1])! : 480
internal let screenHeight = CommandLine.argc > 2 ? Int(CommandLine.arguments[2])! : 480
internal let backgroundColor: RGB = Color.pink.raw
internal let fps = 60

struct Content: View {
    var body: some View {
        MetalView(setup, loop)
            .frame(width: CGFloat(screenWidth), height: CGFloat(screenHeight))
    }
}

private func setup() {
    NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDragged, .leftMouseDown]) { event in
        plot(event.locationInWindow, with: 0xFFFFFF)
        return event
    }
}

private func loop() {
    plot(Int.random(in: 0..<screenWidth), Int.random(in: 0..<screenHeight), with: 0xFFFFFF)
}
