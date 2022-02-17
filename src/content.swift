import Darwin
import SwiftUI
import MetalKit

internal let screenWidth = CommandLine.argc > 1 ? Int(CommandLine.arguments[1])! : 480
internal let screenHeight = CommandLine.argc > 2 ? Int(CommandLine.arguments[2])! : 480
internal let density = CommandLine.argc > 3 ? CGFloat(Float(CommandLine.arguments[3])!) : 1
internal let backgroundColor: RGBA = Color.pink.raw
internal let fps = 60
internal let global = Global()

class Global: ObservableObject {
    @Published var color: Color = .white
}

struct Content: View {
    @EnvironmentObject var global: Global

    var body: some View {
        ZStack(alignment: .topTrailing) {
            MetalView(width: screenWidth, height: screenHeight, setup, loop)
            ColorPicker("", selection: $global.color).padding()
        }
    }
}

private func setup() {
    NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDragged, .leftMouseDown]) { event in
        plot(event.locationInWindow, with: global.color.raw)
        return event
    }
    NSEvent.addLocalMonitorForEvents(matching: [.rightMouseDown]) { event in
        screen.shouldClear = true
        return event
    }
}

private func loop() {
//    plot(Int.random(in: 0..<screenWidth), Int.random(in: 0..<screenHeight), with: 0xffffffff)
}
