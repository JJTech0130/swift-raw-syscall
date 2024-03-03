import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.argumentList.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}

/// Implementation of `syscall` macro, which takes an Int (the syscall number) and zero or more arguments to the syscall, and returns and Int
/// It expands to include manual `dlsym`, and casting to a C function which has 7 filler arguments so that the syscall arguements are on the stack
public struct SyscallMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        print("expanding syscall")
        guard let number = node.argumentList.first?.expression.as(IntegerLiteralExprSyntax.self) else {
            fatalError("compiler bug: the macro does not have any arguments")
        }
        
        // Swift can't natively call variadic functions, so we need to emit dlsym calls and manually cast it
        let args = node.argumentList.dropFirst().map { $0.expression }
        // Make sure all argument types can be converted to UInt64
        var emit = "{\n"
        emit += "let _syscallPtr = dlsym(dlopen(nil, RTLD_NOW), \"syscall\")\n"
        emit += "typealias _syscall_t = @convention(c) (Int32, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, " // 1 less since we add one after args (so that there isn't an extra ,)
        
        for _ in 0..<args.count {
            emit += "UInt64, "
        }
        
        emit += "UInt64) -> Int\n"
        
        emit += "let _syscall = unsafeBitCast(_syscallPtr, to: _syscall_t.self)\n"
        emit += "return _syscall(\(number), 0, 0, 0, 0, 0, 0, 0"
        
        for arg in args {
            emit += ", \(arg)"
        }
        
        emit += ")}()\n"

        return ExprSyntax(stringLiteral: emit)
        
        
    }
}

@main
struct RawSyscallPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SyscallMacro.self,
    ]
}
