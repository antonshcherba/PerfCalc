//
//  Shaders.metal
//  PerfCalc
//
//  Created by Anton Shcherba on 11/12/19.
//  Copyright © 2019 Anton Shcherba. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void add_arrays(device const float* inA,
                       device const float* inB,
                       device float* result,
                       uint index [[thread_position_in_grid]]) {
    
    result[index] = inA[index] + inB[index];
}

