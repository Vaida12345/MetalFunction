#include <metal_stdlib>
using namespace metal;

constant bool enabled [[function_constant(0)]];

kernel void add_const(device float *data,
                      uint id [[ thread_position_in_grid ]]) {
    if (enabled)
        data[id] += 5.0;
}
