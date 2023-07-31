const cmd = @import("./command.zig");
pub const Lexer = @import("./lexer.zig");
pub const Parser = @import("./parser.zig");

pub const Command = cmd.Command;
pub const Argument = cmd.Argument;
pub const Option = cmd.Option;

test {
    const refAllDecls = @import("std").testing.refAllDecls;

    refAllDecls(Lexer);
    refAllDecls(Parser);
}
