//
//  ViewController.swift
//  PerfCalc
//
//  Created by Anton Shcherba on 11/12/19.
//  Copyright © 2019 Anton Shcherba. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import MetalPerformanceShaders

class ViewController: UIViewController {

    let device = MTLCreateSystemDefaultDevice()!
    @IBOutlet weak var someImageView: UIImageView!
    
    var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        let metalAdder = MetalAdder.init(with: device)
//        metalAdder.prepareData()
//        metalAdder.sendComputeCommand()
        
        
//        let metalView = MTKView(frame: .zero, device: device)
//        view.addSubview(metalView)
//        metalView.pin(toEdges: view)
        
//        metalView.clearColor = MTLClearColorMake(0, 1, 1, 1)
//        metalView.enableSetNeedsDisplay = true
        
        
//        renderer = .init(mtkView: metalView)
//        metalView.delegate = renderer
        
        
        makeTexture1(device: device)
    }
    
    func makeTexture1(device: MTLDevice) {
        
        
        guard let queue = device.makeCommandQueue() else { return }
        guard let buffer = queue.makeCommandBuffer() else { return }
        guard let encoder = buffer.makeComputeCommandEncoder() else { return }

        let text = encodeAddCommand(computeEncoder: encoder)

        buffer.commit()
        buffer.waitUntilCompleted()

        let ciImage = CIImage.init(mtlTexture: text, options: [.applyOrientationProperty: true])!.oriented(CGImagePropertyOrientation.downMirrored)
        self.someImageView.image = UIImage.init(ciImage: ciImage)
        
//        let region = MTLRegion.init(origin: MTLOrigin(x: 0, y: 0, z: 0), size: MTLSize.init(width: cgImage.width, height: cgImage.height, depth: 1))
//        let bytesPerRow = cgImage.bytesPerRow
//        texture?.replace(region: region, mipmapLevel: 0, withBytes: <#T##UnsafeRawPointer#>, bytesPerRow: bytesPerRow)
    }
    
    func encodeAddCommand(computeEncoder: MTLComputeCommandEncoder) -> MTLTexture {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("failed default library")
        }
        
        guard let addFunction = library.makeFunction(name: "compute") else {
            fatalError("failed addFunction")
        }
        
        
        guard let mAddFunctionPSO = try? device.makeComputePipelineState(function: addFunction) else {
            fatalError("failed create pipeline")
        }
        
        computeEncoder.setComputePipelineState(mAddFunctionPSO)
        let inTexture = makeTexture()
        let outTexture = newTexture(for: inTexture!)
        computeEncoder.setTexture(inTexture, index: 0)
        computeEncoder.setTexture(outTexture, index: 1)
//        computeEncoder.setBuffer(mBufferA, offset: 0, index: 0)
//        computeEncoder.setBuffer(mBufferB, offset: 0, index: 1)
//        computeEncoder.setBuffer(mBufferResult, offset: 0, index: 2)
        
        let arrayLength = 32
        let gridSize = MTLSize.init(width: arrayLength, height: arrayLength, depth: 1)
        
        var threadGroupSize1 = mAddFunctionPSO.threadExecutionWidth
        if threadGroupSize1 > arrayLength {
            threadGroupSize1 = arrayLength
        }
        
//        let threadGroupSize = MTLSize.init(width: threadGroupSize1, height: threadGroupSize1, depth: 1)
//        computeEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadGroupSize)
        
        let config = makeThreadgroupsConfig(
            textureWidth: outTexture!.width,
            textureHeight: outTexture!.height,
            threadExecutionWidth: mAddFunctionPSO.threadExecutionWidth,
            maxTotalThreadsPerThreadgroup: mAddFunctionPSO.maxTotalThreadsPerThreadgroup
        )
        
        computeEncoder.dispatchThreadgroups(config.threadgroupsPerGrid, threadsPerThreadgroup: config.threadsPerThreadgroup)
        
        computeEncoder.endEncoding()
        
        return outTexture!
    }
    
    func makeTexture() -> MTLTexture? {
        let image = UIImage.init(named: "car.jpg")
        guard let cgImage = image?.cgImage else { return nil }
        
        let textureDesc = MTLTextureDescriptor()
        
        textureDesc.pixelFormat = MTLPixelFormat.rgba8Unorm
        textureDesc.width = cgImage.width
        textureDesc.height = cgImage.height
        
        //        let texture = device.makeTexture(descriptor: textureDesc)
        
        let textureLoader = MTKTextureLoader.init(device: device)
        
        guard let texture = try? textureLoader.newTexture(cgImage: cgImage, options: nil/*[.textureStorageMode: NSNumber(value: MTLStorageMode.shared.rawValue)]*/) else { return nil }
        return texture
    }
    
    func newTexture(for texture: MTLTexture) -> MTLTexture? {
        let outTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: texture.pixelFormat,
            width: texture.width,
            height: texture.height,
            mipmapped: false
        )
        outTextureDescriptor.usage = [.shaderWrite, .shaderRead]
        guard let outTexture = device.makeTexture(descriptor: outTextureDescriptor) else {
            return nil
        }
        
        return outTexture
    }
    
    private func makeThreadgroupsConfig(
        textureWidth: Int,
        textureHeight: Int,
        threadExecutionWidth: Int,
        maxTotalThreadsPerThreadgroup: Int
        ) -> (threadgroupsPerGrid: MTLSize, threadsPerThreadgroup: MTLSize) {
        
        let w = threadExecutionWidth
        let h = maxTotalThreadsPerThreadgroup / w
        
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        let horizontalThreadgroupCount = (textureWidth + w - 1) / w
        let verticalThreadgroupCount = (textureHeight + h - 1) / h
        let threadgroupsPerGrid = MTLSizeMake(horizontalThreadgroupCount, verticalThreadgroupCount, 1)
        
        return (threadgroupsPerGrid: threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    }
}

public extension UIView {
    func pin(toEdges containerView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: containerView.topAnchor),
            bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            rightAnchor.constraint(equalTo: containerView.rightAnchor),
            leftAnchor.constraint(equalTo: containerView.leftAnchor)
            ])
    }
    
    func pinSafely(toEdges containerView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor),
            bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor),
            rightAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.rightAnchor),
            leftAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leftAnchor)
            ])
    }
}

