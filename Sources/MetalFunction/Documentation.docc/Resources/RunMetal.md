# Running Metal

Prepare and execute a single use metal function.


## Define the function

To use metal, create a `.metal` file defining the function in Metal Shader Language (MSL).

```c
#include <metal_stdlib>
using namespace metal;

kernel void add_const(device float *data,
                      constant float& other,
                      uint id [[ thread_position_in_grid ]]) {
    data[id] += other;
}
```

## The Swift driver

With this function, we can write Swift driver to use it.

```swift
try await MetalFunction(name: "add_const", bundle: .module)
    .buffer(buffer)
    .bytes(5 as Float)
    .execute(width: buffer.count)
```
