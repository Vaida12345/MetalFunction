
#include <metal_stdlib>
using namespace metal;

kernel void add_five(device float *data,
                      uint id [[ thread_position_in_grid ]]) {
    data[id] += 5.0;
}
