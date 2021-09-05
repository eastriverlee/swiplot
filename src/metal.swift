import SwiftUI
import MetalKit

internal let backgroundColorMetal = backgroundColor.metal
private var setup: () -> () = {}
private var loop: () -> () = {}

struct MetalView: NSViewRepresentable {

    init(_ setup_: @escaping ()->(), _ loop_: @escaping ()->()) {
       setup = setup_
       loop = loop_
    }

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
        view.device = device
        return view
    }

    class Coordinator : NSObject, MTKViewDelegate {
        let device = MTLCreateSystemDefaultDevice()!
        var commandQueue: MTLCommandQueue!

        override init() {
            commandQueue = device.makeCommandQueue()!
            setup()
            super.init()
        }

        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable, let commandBuffer = commandQueue.makeCommandBuffer() else { return }
            loop()
            commandBuffer.overwrite(drawable.texture, with: screen.texture)
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
    }

    func updateNSView(_ nsView: MTKView, context: NSViewRepresentableContext<MetalView>) { }
}

extension MTLCommandBuffer {
    func overwrite(_ original: MTLTexture, with replacement: MTLTexture) {
        if let encoder = makeBlitCommandEncoder() {
            encoder.copy(from: replacement, to: original)
            encoder.endEncoding()
        }
    }
}
