//
//  Renderer.swift
//  PerfCalc
//
//  Created by Anton Shcherba on 11/20/19.
//  Copyright © 2019 Anton Shcherba. All rights reserved.
//

import Foundation
import MetalKit
import Metal

class Renderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    
    init(mtkView: MTKView) {
        self.device = mtkView.device!
        self.commandQueue = device.makeCommandQueue()!
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let passDescriptor = view.currentRenderPassDescriptor else { return }
        guard let buffer = commandQueue.makeCommandBuffer() else { return }
        guard let encoder = buffer.makeRenderCommandEncoder(descriptor: passDescriptor) else { return }
        
        encoder.endEncoding()
        
        
        guard let drawable = view.currentDrawable else { return }
        buffer.present(drawable)
        
        buffer.commit()
    }
}
