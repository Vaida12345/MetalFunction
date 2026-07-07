import Testing
import MetalFunction

@Test func example() async throws {
    let buffer = UnsafeMutableBufferPointer<Float>.allocate(capacity: 5)
    _ = buffer.initialize(from: stride(from: 1, through: 5, by: 1))
    
    try await MetalFunction(name: "add_five", bundle: .module)
        .buffer(buffer)
        .execute(width: 5)
    
    #expect(Array(buffer) == [6, 7, 8, 9, 10])
}

@Test func specialize() async throws {
    let buffer = UnsafeMutableBufferPointer<Float>.allocate(capacity: 5)
    _ = buffer.initialize(from: stride(from: 1, through: 5, by: 1))
    
    try await MetalFunction(name: "add_const", bundle: .module, constants: [.bool(false)])
        .buffer(buffer)
        .execute(width: 5)
    
    #expect(Array(buffer) == [1, 2, 3, 4, 5])
}
