import SwiftUI
import MetalKit

let fps = 60
let backgroundColor: UInt32 = 0x004040

let scale = Int(NSScreen.main!.backingScaleFactor)
class Screen {
    var texture: MTLTexture
    var data: UnsafeMutablePointer<UInt32>
    var width: Int
    var height: Int
    var line: Int

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
        data = buffer.contents().assumingMemoryBound(to: UInt32.self)
        let count = (width-1) + (height-1)*line/4
        for i in 0..<count {
            data[i] = backgroundColor
        }
    }
}

var screen = Screen(width: screenWidth, height: screenHeight)

func plot(_ x_: Int, _ y_: Int, with color: UInt32) {
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

struct MetalView: NSViewRepresentable {

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: NSViewRepresentableContext<MetalView>) -> MTKView {
        let device = MTLCreateSystemDefaultDevice()!
        let view = MTKView()
        
        view.delegate = context.coordinator
        view.preferredFramesPerSecond = fps
        view.framebufferOnly = false
        view.drawableSize = view.frame.size
        view.enableSetNeedsDisplay = true
        view.device = device
        return view
    }

    func updateNSView(_ nsView: MTKView, context: NSViewRepresentableContext<MetalView>) {
    }

    class Coordinator : NSObject, MTKViewDelegate {
        let device = MTLCreateSystemDefaultDevice()!
        var commandQueue: MTLCommandQueue!

        override init() {
            commandQueue = device.makeCommandQueue()!
            super.init()
        }

        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable else { return }
            let commandBuffer = commandQueue.makeCommandBuffer()!
            let descriptor = view.currentRenderPassDescriptor!

            if let encoder = commandBuffer.makeBlitCommandEncoder() {
                let origin = MTLOriginMake(0,0,0)
                let size = MTLSizeMake(screen.texture.width, screen.texture.height, 1)
                encoder.copy(
                    from:screen.texture, sourceSlice:0, sourceLevel:0, sourceOrigin: origin, sourceSize: size,
                    to:drawable.texture, destinationSlice:0, destinationLevel:0, destinationOrigin: origin
                )
                encoder.endEncoding()
            }
            descriptor.colorAttachments[0].loadAction = .load
            commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)?.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
    }
}
