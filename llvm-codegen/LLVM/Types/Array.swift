import CLLVM

/// `ArrayType` is a very simple derived type that arranges elements
/// sequentially in memory. `ArrayType` requires a size (number of elements) and
/// an underlying data type.
public struct ArrayType: TypeRef {
    private var llvm: LLVMTypeRef

    /// Retrieves the underlying LLVM type object.
    public var typeRef: LLVMTypeRef { llvm }

    /// The type of elements in this array.
    public let elementType: TypeRef

    /// Array counter kind
    public enum ArrayCountKind {
        case x32(UInt32)
        case x64(UInt64)
    }

    /// The number of elements in this array.
    public let count: ArrayCountKind

    /// Creates an array type from an underlying element type and count.
    /// Maximum size of array limited by `UInt32`
    /// The created type will exist in the context that its element type exists in.
    public init(elementType: TypeRef, count: UInt32) {
        self.elementType = elementType
        self.count = .x32(count)
        self.llvm = LLVMArrayType(elementType.typeRef, count)
    }

    /// Creates an array type from an underlying element type and count.
    /// Maximum size of array limited by `UInt64`
    /// The created type will exist in the context that its element type exists in.
    public init(elementType: TypeRef, count: UInt64) {
        self.elementType = elementType
        self.count = .x64(count)
        self.llvm = LLVMArrayType2(elementType.typeRef, count)
    }

    /// Obtain the length of an array type for 32 bits array size.
    /// This only works on types that represent arrays.
    public static func getArrayLength(arrayType: TypeRef) -> UInt32 {
        LLVMGetArrayLength(arrayType.typeRef)
    }

    /// Obtain the length of an array type for 64 bits array size.
    /// This only works on types that represent arrays.
    public static func gtArrayLength2(arrayType: TypeRef) -> UInt64 {
        LLVMGetArrayLength2(arrayType.typeRef)
    }

    /// Get the element type of an array  type.
    public static func getElementType(arrayType: TypeRef) -> LLVMTypeRef {
        LLVMGetElementType(arrayType.typeRef)
    }

    /// Returns type's subtypes
    public static func getSubtypes(arrayType: TypeRef) -> [LLVMTypeRef?] {
        let subtypeCount = LLVMGetNumContainedTypes(arrayType.typeRef)
        var subtypes = [LLVMTypeRef?](repeating: nil, count: Int(subtypeCount))
        subtypes.withUnsafeMutableBufferPointer { bufferPointer in
            LLVMGetSubtypes(arrayType.typeRef, bufferPointer.baseAddress)
        }
        return subtypes
    }
}

extension ArrayType: Equatable {
    public static func == (lhs: ArrayType, rhs: ArrayType) -> Bool {
        return lhs.typeRef == rhs.typeRef
    }
}