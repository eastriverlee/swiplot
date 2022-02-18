import SwiftUI
import MetalKit
import MetalPerformanceShaders

internal let device = MTLCreateSystemDefaultDevice()!
internal let backgroundColorMetal = backgroundColor.metal
private var setup: () -> () = {}
private var loop: () -> () = {}


struct MetalView: View {
    private var width: Int
    private var height: Int

    init(width: Int, height: Int, _ setup_: @escaping ()->(), _ loop_: @escaping ()->()) {
       setup = setup_
       loop = loop_
       self.width = width
       self.height = height
    }

    var body: some View {
        _MetalView()
        .frame(width: CGFloat(width), height: CGFloat(height))
    }
}

private struct _MetalView: NSViewRepresentable {

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: NSViewRepresentableContext<_MetalView>) -> MTKView {
        let view = MTKView()
        
        view.delegate = context.coordinator
        view.preferredFramesPerSecond = fps
        view.framebufferOnly = false
        view.drawableSize = view.frame.size
        view.device = device
        return view
    }

    class Coordinator : NSObject, MTKViewDelegate {
        var commandQueue: MTLCommandQueue!

        override init() {
            commandQueue = device.makeCommandQueue()!
            setup()
            super.init()
        }

        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable, let commandBuffer = commandQueue.makeCommandBuffer() else { return }
            loop()
            if screen.shouldClear {
                commandBuffer.overwrite(screen.texture, with: clear.texture)
                screen.shouldClear = false
            }
            commandBuffer.overwrite(drawable.texture, with: screen.texture)
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }

        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            print(view.drawableSize, "->", size)
        }
    }

    func updateNSView(_ nsView: MTKView, context: NSViewRepresentableContext<_MetalView>) { }
}

private let filter = MPSImageLanczosScale(device: device)
private var transform = MPSScaleTransform()
extension MTLCommandBuffer {
    func overwrite(_ original: MTLTexture, with replacement: MTLTexture) {
        let scale = CGFloat(original.width) / CGFloat(replacement.width)
        if scale == 1 {
            if let encoder = makeBlitCommandEncoder() {
                encoder.copy(from: replacement, to: original)
                encoder.endEncoding()
            }
        } else {
            transform.scaleX = scale
            transform.scaleY = scale
            withUnsafePointer(to: &transform) { transform in
                filter.scaleTransform = transform
                filter.encode(commandBuffer: self, sourceTexture: replacement, destinationTexture: original)
            }
        }
    }
}
