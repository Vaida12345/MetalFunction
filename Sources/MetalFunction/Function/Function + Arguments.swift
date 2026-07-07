//
//  Function + Arguments.swift
//  MetalFunction
//
//  Created by Vaida on 2026-07-07.
//

import Metal


extension MetalFunction {
    
    @inlinable
    func offsetPlusOne() -> MetalFunction {
        self.offset += 1
        return self
    }
    
    /// Pass a `MTLBuffer`.
    @inlinable
    public func buffer(_ buffer: any MTLBuffer) -> MetalFunction {
        self.commandEncoder.setBuffer(buffer, offset: 0, index: self.offset)
        return offsetPlusOne()
    }
    
    /// Binds a `UnsafeMutableBufferPointer`.
    ///
    /// - Important: `buffer` is passed without copying, and it is the caller's responsibility to keep it valid for the duration of metal execution.
    @inlinable
    public func buffer<T>(
        _ buffer: UnsafeMutableBufferPointer<T>,
        deallocator: (@Sendable (UnsafeMutableRawPointer, Int) -> Void)? = nil
    ) throws -> MetalFunction where T: BitwiseCopyable {
        return try self.buffer(start: buffer.baseAddress!, count: buffer.count, deallocator: deallocator)
    }
    
    /// Binds a `UnsafeMutablePointer`.
    ///
    /// - Important: `buffer` is passed without copying, and it is the caller's responsibility to keep it valid for the duration of metal execution.
    @inlinable
    public func buffer<T>(
        start: UnsafeMutablePointer<T>,
        count: Int,
        deallocator: (@Sendable (UnsafeMutableRawPointer, Int) -> Void)? = nil
    ) throws -> MetalFunction where T: BitwiseCopyable {
        let label = "Buffer<\(T.self)>(cpuAddress: \(start), count: \(count))"
        guard let buffer = try MetalExecutor.get().computeDevice.makeBuffer(bytesNoCopy: start, length: count &* MemoryLayout<T>.stride, deallocator: deallocator) else {
            throw ExecutionError.cannotCreateBuffer(label)
        }
        buffer.label = label
        
        return self.buffer(buffer)
    }
    
    /// Copies an array as input buffer.
    @inlinable
    public func buffer<T>(
        copying array: Array<T>
    ) throws -> MetalFunction where T: BitwiseCopyable {
        let label = "Buffer<\(T.self)>(count: \(array.count))"
        guard let buffer = try MetalExecutor.get().computeDevice.makeBuffer(bytes: array, length: array.count &* MemoryLayout<T>.stride) else {
            throw ExecutionError.cannotCreateBuffer(label)
        }
        buffer.label = label
        
        return self.buffer(buffer)
    }
    
    /// Copies data directly to the GPU to populate an entry in the buffer argument table.
    ///
    /// - Important: This method only works for data smaller than 4 kilobytes that doesn’t persist. Create an MTLBuffer instance if your data exceeds 4 KB, needs to persist on the GPU, or you access results on the CPU.
    ///
    /// This method allows Metal to copy data efficiently onto the GPU without the need for your own buffer. Binding data directly can improve performance, especially when making many small allocations.
    @inlinable
    public func bytes<T>(_ value: T) -> MetalFunction where T: BitwiseCopyable {
        withUnsafePointer(to: value) {
            self.commandEncoder.setBytes($0, length: MemoryLayout<T>.size, index: self.offset)
        }
        return offsetPlusOne()
    }
    
    /// Copies data directly to the GPU to populate an entry in the buffer argument table.
    ///
    /// - Important: This method only works for data smaller than 4 kilobytes that doesn’t persist. Create an MTLBuffer instance if your data exceeds 4 KB, needs to persist on the GPU, or you access results on the CPU.
    ///
    /// This method allows Metal to copy data efficiently onto the GPU without the need for your own buffer. Binding data directly can improve performance, especially when making many small allocations.
    @inlinable
    public func bytes<T>(_ value: Array<T>) -> MetalFunction where T: BitwiseCopyable {
        value.withUnsafeBytes {
            self.commandEncoder.setBytes($0.baseAddress!, length: MemoryLayout<T>.stride * value.count, index: self.offset)
        }
        return offsetPlusOne()
    }
    
    
}
