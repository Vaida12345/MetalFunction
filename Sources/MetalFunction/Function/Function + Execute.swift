//
//  Function + Execute.swift
//  MetalFunction
//
//  Created by Vaida on 2026-07-07.
//

import Metal
import Foundation

func optimalThreadsPerThreadgroup(
    for pipelineState: MTLComputePipelineState,
    gridSize: MTLSize
) -> MTLSize {
    precondition(gridSize.width > 0)
    precondition(gridSize.height > 0)
    precondition(gridSize.depth > 0)
    
    let simdWidth = max(1, pipelineState.threadExecutionWidth)
    let maxThreads = max(1, pipelineState.maxTotalThreadsPerThreadgroup)
    
    let width = gridSize.width
    let height = gridSize.height
    let depth = gridSize.depth
    
    // 1D case
    if height == 1 && depth == 1 {
        let limit = min(width, maxThreads)
        
        if limit >= simdWidth {
            let rounded = (limit / simdWidth) * simdWidth
            return MTLSize(width: max(1, rounded), height: 1, depth: 1)
        } else {
            return MTLSize(width: max(1, limit), height: 1, depth: 1)
        }
    }
    
    // Prefer one SIMD group along X.
    let x: Int
    if width >= simdWidth {
        x = min(simdWidth, maxThreads)
    } else {
        x = min(width, maxThreads)
    }
    
    let remaining = max(1, maxThreads / x)
    
    // 2D case
    if depth == 1 {
        let y = min(height, remaining)
        
        return MTLSize(
            width: max(1, x),
            height: max(1, y),
            depth: 1
        )
    }
    
    // 3D case.
    // Choose Y/Z to use as many remaining threads as possible while roughly
    // matching the grid's Y/Z aspect ratio.
    var bestY = 1
    var bestZ = 1
    var bestTotal = 1
    var bestAspectCost = Double.greatestFiniteMagnitude
    
    let maxY = max(1, min(height, remaining))
    
    for y in 1...maxY {
        let z = min(depth, remaining / y)
        let total = y * z
        
        guard total > 0 else { continue }
        
        let candidateAspect = Double(y) / Double(z)
        let gridAspect = Double(height) / Double(depth)
        let aspectCost = abs(log(candidateAspect / gridAspect))
        
        if total > bestTotal ||
            (total == bestTotal && aspectCost < bestAspectCost) {
            bestY = y
            bestZ = z
            bestTotal = total
            bestAspectCost = aspectCost
        }
    }
    
    return MTLSize(
        width: max(1, x),
        height: max(1, bestY),
        depth: max(1, bestZ)
    )
}


extension MetalFunction {
    
    /// Performs and waits for completion.
    public consuming func execute(width: Int, height: Int = 1, depth: Int = 1) async throws {
        let gridSize = MTLSize(width: width, height: height, depth: depth)
        self.commandEncoder.dispatchThreads(
            gridSize,
            threadsPerThreadgroup: optimalThreadsPerThreadgroup(for: self.pipelineState, gridSize: gridSize)
        )
        
        self.commandEncoder.endEncoding()
        self.commandBuffer.commit()
        
        await self.commandBuffer.completed()
        
        if let error = commandBuffer.error {
            throw error
        }
    }
    
}
