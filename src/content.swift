import Darwin
import SwiftUI
import MetalKit

private let maxDensity = NSScreen.screens.map{$0.backingScaleFactor}.max() ?? 1
internal let screenWidth = CommandLine.argc > 1 ? Int(CommandLine.arguments[1])! : 480
internal let screenHeight = CommandLine.argc > 2 ? Int(CommandLine.arguments[2])! : 480
internal let density = CommandLine.argc > 3 ? CGFloat(Float(CommandLine.arguments[3])!) : maxDensity
internal let backgroundColor: RGBA = Color.white.raw
internal let fps = 60
internal let global = Global()

class Global: ObservableObject {
    @Published var color: Color = .pink
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
    line(from: .init(x: 0, y: 0), to: .init(x: 240, y: 240), with: global.color.raw)
    line(from: .init(x: 0, y: 0), to: .init(x: 400, y: 100), with: global.color.raw)
    line(from: .init(x: 240, y: 240), to: .init(x: 400, y: 100), with: global.color.raw)
    NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown]) { event in
        plot(event.locationInWindow, with: global.color.raw)
        connectNext = true
        return event
    }
    NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDragged]) { event in
        plot(event.locationInWindow, with: global.color.raw)
        return event
    }
    NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp]) { event in
        connectNext = false
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
