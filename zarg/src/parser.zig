const std = @import("std");
const mem = std.mem;
const Lexer = @import("./lexer.zig");
const cmd = @import("./command.zig");

const Parser = @This();

allocator: mem.Allocator,

pub fn init(allocator: mem.Allocator) Parser {
    return .{ .allocator = allocator };
}

pub fn resolve(self: *Parser, root: cmd.Command, results: []Lexer.Result) mem.Allocator.Error!?cmd.Command {
    var args = std.ArrayList([]const u8).init(self.allocator);

    for (results) |res| switch (res) {
        .argument => |a| try args.append(a),
        else => continue,
    };

    return self.resolve_internal(root, try args.toOwnedSlice());
}

fn resolve_internal(self: *Parser, root: cmd.Command, args: [][]const u8) ?cmd.Command {
    if (args.len == 0 or root.commands.len != 0) return root;

    for (root.commands) |command| {
        if (mem.eql(u8, command.name, args[0])) {
            return self.resolve_internal(command, args[1..]);
        }
    }
    if (root.arguments.len != 0) return root;

    return null;
}

// pub fn sort(self: *Parser, root: cmd.Command, results: []Result) !Context {}

test "resolving commands" {
    const expect = std.testing.expect;
    // const expectEqualDeep = std.testing.expectEqualDeep;

    var lexer = Lexer.init(std.testing.allocator, "foo bar");
    defer lexer.deinit();
    try lexer.read();

    const child = cmd.Command{
        .name = "bar",
        .commands = &.{},
        .arguments = &.{},
        .options = &.{},
        .action = undefined,
    };

    const root = cmd.Command{
        .name = "foo",
        .commands = &.{child},
        .arguments = &.{},
        .options = &.{},
        .action = undefined,
    };

    var parser = Parser.init(std.testing.allocator);
    var command = try parser.resolve(root, lexer.results.?);

    try expect(command != null);
    // try expectEqualDeep(command.?, child);
}
