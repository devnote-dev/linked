const cmd = @import("./command.zig");
pub const Lexer = @import("./lexer.zig");

pub const Command = cmd.Command;
pub const Argument = cmd.Argument;
pub const Option = cmd.Option;

test {
    @import("std").testing.refAllDecls(Lexer);
}
