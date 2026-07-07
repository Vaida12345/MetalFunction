//
//  MetalExecutor.swift
//  MetalFunction
//
//  Created by Vaida on 2026-07-07.
//

@preconcurrency
import Metal


/// The shared executor.
@usableFromInline
final actor MetalExecutor {
    
    /// The execution device used in this package.
    @usableFromInline
    let computeDevice: any MTLDevice
    let commandQueue: MTLCommandQueue
    
    var libraries: [Bundle : MTLLibrary] = [:]
    
    // MARK: - Make Function
    
    var functions: [MetalFunction.LookupKey : MetalFunction.Cache] = [:]
    
    
    func makeFunction(
        name: String,
        bundle: Bundle,
        constants: sending [MetalFunction.Constant]
    ) async throws -> (function: any MTLFunction, pipelineState: any MTLComputePipelineState) {
        let lookupKey = MetalFunction.LookupKey(bundle: bundle, name: name, constants: constants)
        
        if let cache = self.functions[lookupKey] {
            return (cache.function, cache.pipelineState)
        }
        
        let library: MTLLibrary
        if let _library = self.libraries[bundle] {
            library = _library
        } else {
            let _library = try self.computeDevice.makeDefaultLibrary(bundle: bundle)
            self.libraries[bundle] = _library
            library = _library
        }
        
        let constantValues = MTLFunctionConstantValues()
        for (index, constant) in constants.enumerated() {
            constant.populate(constants: constantValues, index: index)
        }
        
        let function = try await library.makeFunction(name: name, constantValues: constantValues)
        function.label = "\(name)<\(constants.map(\.description).joined(separator: ", "))>"
        
        let pipelineState = try await self.computeDevice.makeComputePipelineState(function: function)
        
        let cache = MetalFunction.Cache(function: function, pipelineState: pipelineState)
        self.functions[lookupKey] = cache
        
        return (function, pipelineState)
    }
    
    
    // MARK: - Initializer
    
    private init?() {
#if !arch(arm64)
        return nil // not supported on intel.
#endif
        guard let device = MTLCreateSystemDefaultDevice(),
              device.supportsFamily(.apple4) else { return nil }
        
        guard let commandQueue = device.makeCommandQueue(maxCommandBufferCount: 8) else { return nil }
        
        self.computeDevice = device
        self.commandQueue = commandQueue
        self.libraries = [:]
    }
    
    /// The shared instance.
    ///
    /// Returns `nil` if metal is not supported, or if non-uniform grid size is not supported.
    @usableFromInline
    static let shared = MetalExecutor()
    
    @inlinable
    internal static func get() throws -> MetalExecutor {
        if let shared {
            return shared
        } else {
            throw ExecutionError.notSupported
        }
    }
    
}
