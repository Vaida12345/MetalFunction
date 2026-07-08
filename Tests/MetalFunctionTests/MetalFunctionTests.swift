import Testing
import MetalFunction

@Test func example() async throws {
    let buffer = UnsafeMutableBufferPointer<Float>.allocate(capacity: 5)
    defer { buffer.deallocate() }
    _ = buffer.initialize(from: stride(from: 1, through: 5, by: 1))
    
    try await MetalFunction(name: "add_five", bundle: .module)
        .buffer(buffer)
        .execute(width: 5)
    
    #expect(Array(buffer) == [6, 7, 8, 9, 10])
}

@Test func reuseFunction() async throws {
    let buffer = UnsafeMutableBufferPointer<Float>.allocate(capacity: 5)
    defer { buffer.deallocate() }
    _ = buffer.initialize(from: stride(from: 1, through: 5, by: 1))
    
    try await MetalFunction(name: "add_five", bundle: .module)
        .buffer(buffer)
        .execute(width: 5)
    
    #expect(Array(buffer) == [6, 7, 8, 9, 10])
    
    try await MetalFunction(name: "add_five", bundle: .module)
        .buffer(buffer)
        .execute(width: 5)
    
    #expect(Array(buffer) == [11, 12, 13, 14, 15])
}

@Test func specialize() async throws {
    let buffer = UnsafeMutableBufferPointer<Float>.allocate(capacity: 5)
    defer { buffer.deallocate() }
    _ = buffer.initialize(from: stride(from: 1, through: 5, by: 1))
    
    try await MetalFunction(name: "add_const", bundle: .module, constants: [.bool(false)])
        .buffer(buffer)
        .execute(width: 5)
    
    #expect(Array(buffer) == [1, 2, 3, 4, 5])
}

@Test func bytes() async throws {
    let buffer = UnsafeMutableBufferPointer<Float>.allocate(capacity: 5)
    defer { buffer.deallocate() }
    _ = buffer.initialize(from: stride(from: 1, through: 5, by: 1))
    
    try await MetalFunction(name: "add_constant", bundle: .module)
        .buffer(buffer)
        .bytes(5 as Float)
        .execute(width: 5)
    
    #expect(Array(buffer) == [6, 7, 8, 9, 10])
}
