import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(RawSyscall)
import RawSyscall
#endif

final class RawSyscallTests: XCTestCase {
    func testSyscallMacro() throws {
        #if canImport(RawSyscall)
        print("test syscall GETPID: ")
        print(#syscall(20))
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
