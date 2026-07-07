//
//  ExecutionError.swift
//  MetalFunction
//
//  Created by Vaida on 2026-07-07.
//


/// Errors thrown by a `MetalFunction`.
public enum ExecutionError: Error {
    /// Metal is not supported
    case notSupported
    
    case cannotCreateCommandBuffer
    case cannotCreateCommandEncoder
    case cannotCreateBuffer(String)
}
