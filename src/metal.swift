import SwiftUI
import MetalKit

let fps = 60
let backgroundColor = Color(red: 0, green: 0.7, blue: 0.2).metal

struct MetalView: NSViewRepresentable {

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: NSViewRepresentableContext<MetalView>) -> MTKView {
        let view = MTKView()
        let device = MTLCreateSystemDefaultDevice()!
        
        view.delegate = context.coordinator
        view.preferredFramesPerSecond = fps
        view.framebufferOnly = false
        view.clearColor = backgroundColor
        view.drawableSize = view.frame.size
        view.enableSetNeedsDisplay = true
        view.device = device
        return view
    }

    func updateNSView(_ nsView: MTKView, context: NSViewRepresentableContext<MetalView>) {
    }

    class Coordinator : NSObject, MTKViewDelegate {
        var parent: MetalView
        var commandQueue: MTLCommandQueue!

        init(_ parent: MetalView) {
            let device = MTLCreateSystemDefaultDevice()! 

            self.parent = parent
            commandQueue = device.makeCommandQueue()!
            super.init()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        }

        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable else { return }
            let commandBuffer = commandQueue.makeCommandBuffer()!
            let descriptor = view.currentRenderPassDescriptor!

            let render = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
            render?.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}
