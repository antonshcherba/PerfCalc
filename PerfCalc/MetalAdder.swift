//
//  MetalAdder.swift
//  PerfCalc
//
//  Created by Anton Shcherba on 11/12/19.
//  Copyright © 2019 Anton Shcherba. All rights reserved.
//

import Foundation
import Metal

class MetalAdder {
    let mDevice: MTLDevice
    var mAddFunctionPSO: MTLComputePipelineState
    var mCommandQueue: MTLCommandQueue
    
    var mBufferA: MTLBuffer!
    var mBufferB: MTLBuffer!
    var mBufferResult: MTLBuffer!
    
    let arrayLength = 1 << 24
    lazy var bufferSize = arrayLength * MemoryLayout.size(ofValue: Float.self)
    
    init(with device: MTLDevice) {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("failed default library")
        }
        mDevice = device
        
        guard let addFunction = library.makeFunction(name: "add_arrays") else {
            fatalError("failed addFunction")
        }
        
        
        guard let mAddFunctionPSO = try? mDevice.makeComputePipelineState(function: addFunction) else {
            fatalError("failed create pipeline")
        }
        self.mAddFunctionPSO = mAddFunctionPSO
        
        guard let queue = mDevice.makeCommandQueue() else {
            fatalError("failed create command queue")
        }
        
        mCommandQueue = queue
    }
    
    func prepareData() {
        mBufferA = mDevice.makeBuffer(length: bufferSize, options: MTLResourceOptions.storageModeShared)
        mBufferB = mDevice.makeBuffer(length: bufferSize, options: MTLResourceOptions.storageModeShared)
        mBufferResult = mDevice.makeBuffer(length: bufferSize, options: MTLResourceOptions.storageModeShared)

        generateRandomData1(buffer: mBufferA)
        generateRandomData2(buffer: mBufferB)
    }
    
    func generateRandomData1(buffer: MTLBuffer) {
        let ptr = buffer.contents().assumingMemoryBound(to: Float.self)
        for index in 0..<arrayLength {
            ptr[index] = 2
        }
    }
    
    func generateRandomData2(buffer: MTLBuffer) {
        let ptr = buffer.contents().assumingMemoryBound(to: Float.self)
        for index in 0..<arrayLength {
            ptr[index] = 2
        }
    }
    
    func sendComputeCommand() {
        let commandBuffer = mCommandQueue.makeCommandBuffer()
        
        let computeEncoder = commandBuffer?.makeComputeCommandEncoder()
        computeEncoder.map(encodeAddCommand)
        
        commandBuffer?.commit()
        
        commandBuffer?.waitUntilCompleted()
    }
    
    func encodeAddCommand(computeEncoder: MTLComputeCommandEncoder) {
        computeEncoder.setComputePipelineState(mAddFunctionPSO)
        computeEncoder.setBuffer(mBufferA, offset: 0, index: 0)
        computeEncoder.setBuffer(mBufferB, offset: 0, index: 1)
        computeEncoder.setBuffer(mBufferResult, offset: 0, index: 2)
        
        let gridSize = MTLSize.init(width: arrayLength, height: 1, depth: 1)
        
        var threadGroupSize1 = mAddFunctionPSO.threadExecutionWidth
        if threadGroupSize1 > arrayLength {
            threadGroupSize1 = arrayLength
        }
        
        let threadGroupSize = MTLSize.init(width: threadGroupSize1, height: 1, depth: 1)
        computeEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadGroupSize)
        
        computeEncoder.endEncoding()
    }
}
