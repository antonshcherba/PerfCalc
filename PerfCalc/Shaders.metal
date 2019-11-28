//
//  Shaders.metal
//  PerfCalc
//
//  Created by Anton Shcherba on 11/12/19.
//  Copyright © 2019 Anton Shcherba. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

//kernel void add_arrays(device const float* inA,
//                       device const float* inB,
//                       device float* result,
//                       uint index [[thread_position_in_grid]]) {
//    
//    result[index] = inA[index] + inB[index];
//}

kernel void compute(texture2d<float,access::read> inA [[texture(0)]],
                    texture2d<float,access::read_write> result [[texture(1)]],
                    uint2 index [[thread_position_in_grid]]) {
    
    float4 color = inA.read(index);
    result.write(color, index);
}

