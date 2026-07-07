# Running Metal

Prepare and execute a single use metal function.


## Define the function

To use metal, create a `.metal` file defining the function in Metal Shader Language (MSL).

```c
#include <metal_stdlib>
using namespace metal;

kernel void add_five(device float *data,
                     uint id [[ thread_position_in_grid ]]) {
    data[id] += 5.0;
}
```

## The Swift driver

With this function, we can write Swift driver to use it.

```swift
try await MetalFunction(name: "add_five", bundle: .module)
    .buffer(buffer)
    .execute(width: buffer.count)
```
