const Lexer = @import("./lexer.zig");

test {
    @import("std").testing.refAllDecls(Lexer);
}
