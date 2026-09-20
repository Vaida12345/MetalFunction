# MetalFunction

A lightweight Swift Package for loading and executing Metal compute functions with a fluent Swift API.

MetalFunction handles Metal library lookup, compute pipeline creation, argument binding, thread dispatch, command-buffer completion, and pipeline caching.


### Execute the kernel from Swift

Create a `MetalFunction`, bind its arguments in kernel parameter order, and execute it:

```swift
let values = ...

try await MetalFunction(name: "add_constant", bundle: .module)
    .buffer(values)
    .bytes(5 as Float)
    .execute(width: values.count)
```

The `buffer`, `bytes`, and `execute` calls correspond to the Metal function's argument order and execution grid.

### Function constants

`MetalFunction` supports compile-time Metal function constants by specialize the function when creating it:

```swift
try await MetalFunction(name: "add_const", bundle: .module, constants: [.bool(true)])
    .buffer(values)
    .execute(width: values.count)
```

Supported constant types include `Bool`, `UInt32`, `Int32`, `UInt8`, and `Float`.

## API overview

- `MetalFunction(name:bundle:constants:)` loads and specializes a Metal function.
- `buffer(_:)` binds an `MTLBuffer` or mutable buffer pointer.
- `buffer(copying:)` creates a Metal buffer by copying Swift values.
- `bytes(_:)` binds a value or array as constant bytes.
- `execute(width:height:depth:)` dispatches the compute grid and awaits completion.
- `MetalFunction.isSupported` checks whether the current device is supported.

A `MetalFunction` instance represents a single command encoding. Create a new instance for each execution. Compiled functions and pipeline states are cached by bundle, function name, and specialization constants.

## Getting Started

`MetalFunction` uses [Swift Package Manager](https://www.swift.org/documentation/package-manager/). Add a dependency in `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/Vaida12345/MetalFunction.git", from: "1.1.0")
]
```
and then adding the appropriate module to your target dependencies.

### Using Xcode Package support

You can add this framework as a dependency to your Xcode project by clicking File -> Swift Packages -> Add Package Dependency. The package is located at:
```
https://github.com/Vaida12345/MetalFunction.git
```

## Documentation

This package uses [DocC](https://www.swift.org/documentation/docc/) for documentation. [View on Github Pages](https://vaida12345.github.io/MetalFunction/documentation/metalfunction/).
