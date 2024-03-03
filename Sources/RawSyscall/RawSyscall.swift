#if arch(arm64)
/// A macro that calls a raw syscall with the given number and arguments.
/// Only supports ARM64 at the moment due to implementation details.
@freestanding(expression)
public macro syscall(_ number: Int, _ args: Any... = []) -> Int = #externalMacro(module: "RawSyscallMacros", type: "SyscallMacro")
#endif
