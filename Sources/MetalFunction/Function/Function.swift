//
//  MetalFunction.swift
//  MetalFunction
//
//  Created by Vaida on 2026-07-07.
//

@preconcurrency
import Metal


/// The bridge to a Metal function.
public final class MetalFunction {
    
    @usableFromInline
    let pipelineState: any MTLComputePipelineState
    
    /// A batch of GPU commands, not reused.
    @usableFromInline
    let commandBuffer: any MTLCommandBuffer
    
    /// Records compute commands, not reused.
    @usableFromInline
    let commandEncoder: any MTLComputeCommandEncoder
    
    /// Argument offset
    @usableFromInline
    var offset: Int
    
    /// Returns whether metal is supported on this device.
    public nonisolated static var isSupported: Bool {
        MetalExecutor.shared != nil
    }
    
    /// Binds to a Metal function.
    ///
    /// You can pass `constants` to specialize a metal kernel.
    ///
    /// ```c
    /// constant bool enabled [[function_constant(0)]];
    ///
    /// kernel void add_const(device float *data,
    ///                       uint id [[ thread_position_in_grid ]]) {
    ///     if (enabled)
    ///         data[id] += 5.0;
    /// }
    /// ```
    ///
    /// Then, you can create a swift driver that compiles a specialized kernel with `enabled` set to false.
    /// 
    /// ```swift
    /// try await MetalFunction(name: "add_const", bundle: .module, constants: [.bool(false)])
    /// ```
    ///
    /// - Parameters:
    ///   - name: The name of the metal function.
    ///   - bundle: The bundle in which the function is located.
    ///   - constants: Compile-time specialization choice.
    public init(name: String, bundle: Bundle, constants: [Constant] = []) async throws {
        let (_, pipelineStates) = try await MetalExecutor.get().makeFunction(name: name, bundle: bundle, constants: constants)
        self.pipelineState = pipelineStates
        
        guard let commandBuffer = try MetalExecutor.get().commandQueue.makeCommandBuffer() else {
            throw ExecutionError.cannotCreateCommandBuffer
        }
        commandBuffer.label = name
        self.commandBuffer = commandBuffer
        
        guard let commandEncoder = commandBuffer.makeComputeCommandEncoder() else {
            throw ExecutionError.cannotCreateCommandEncoder
        }
        commandEncoder.label = name
        commandEncoder.setComputePipelineState(pipelineStates)
        
        self.commandEncoder = commandEncoder
        self.offset = 0
    }
    
    @inlinable
    internal init(pipelineState: any MTLComputePipelineState, commandBuffer: any MTLCommandBuffer, commandEncoder: any MTLComputeCommandEncoder, offset: Int) {
        self.pipelineState = pipelineState
        self.commandBuffer = commandBuffer
        self.commandEncoder = commandEncoder
        self.offset = offset
    }
    
    deinit {
        if self.offset >= 0 {
            // must call `endEncoding` at least once.
            self.commandEncoder.endEncoding()
        }
    }
    
    struct LookupKey: Hashable {
        let bundle: Bundle
        let name: String
        let constants: [Constant]
    }
    
    struct Cache {
        /// The source metal function
        let function: any MTLFunction
        /// The compiled metal kernel
        let pipelineState: any MTLComputePipelineState
    }
    
    /// A compile-time specialization choice.
    public enum Constant: Hashable, Sendable, CustomStringConvertible {
        case bool(Bool)
        case uint(UInt32)
        case int(Int32)
        case uchar(UInt8)
        case float(Float)
        
        public var description: String {
            switch self {
            case .bool(let bool): bool.description
            case .uint(let uInt32): uInt32.description
            case .int(let int32): int32.description
            case .uchar(let uInt8): uInt8.description
            case .float(let float): float.description
            }
        }
        
        /// Returns `int` casted as `uint32`.
        @inlinable
        public static func uint(_ int: Int) -> Constant {
            .uint(UInt32(int))
        }
        
        func populate(constants: MTLFunctionConstantValues, index: Int) {
            switch self {
            case .bool(var bool):
                // passing a `&` is safe as this is how apple docs says.
                constants.setConstantValue(&bool, type: .bool, index: index)
            case .uint(var uInt32):
                constants.setConstantValue(&uInt32, type: .uint, index: index)
            case .int(var int32):
                constants.setConstantValue(&int32, type: .int, index: index)
            case .uchar(var uInt8):
                constants.setConstantValue(&uInt8, type: .char, index: index)
            case .float(var float):
                constants.setConstantValue(&float, type: .float, index: index)
            }
        }
    }
    
}
