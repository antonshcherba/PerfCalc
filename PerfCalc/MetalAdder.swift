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
        
        
    }
}
