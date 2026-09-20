//
//  add_constant.metal
//  MetalFunction
//
//  Created by Vaida on 2026-07-08.
//

#include <metal_stdlib>
using namespace metal;

kernel void add_constant(device float *data,
                         constant float& other,
                         uint id [[ thread_position_in_grid ]]) {
    data[id] += other;
}
