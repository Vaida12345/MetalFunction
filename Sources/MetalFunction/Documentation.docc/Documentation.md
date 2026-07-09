# ``MetalFunction``

Lightweight one-shot, one Metal kernel package.

## Overview

Use this package to deliver efficient and simple metal execution.

```swift
try await MetalFunction(name: "add_const", bundle: .module)
    .buffer(buffer)
    .execute(width: buffer.count)
```

You can use ``MetalFunction/isSupported`` to determine if metal is supported on a device.


## Topics

### Articles
- <doc:RunMetal>

### APIs
- ``MetalFunction``
- ``ExecutionError``
