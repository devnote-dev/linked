const std = @import("std");

pub const Result = union(enum) {
    argument: []const u8,
    string: []const u8,
    short_flag: []const u8,
    long_flag: []const u8,
};

const Lexer = @This();

allocator: std.mem.Allocator,
input: []const u8,
pos: usize,
results: ?[]Result,

pub fn init(allocator: std.mem.Allocator, input: []const u8) Lexer {
    return .{
        .allocator = allocator,
        .input = input,
        .pos = 0,
        .results = null,
    };
}

pub fn deinit(self: *Lexer) void {
    if (self.results) |res| self.allocator.free(res);
}

pub fn read(self: *Lexer) !void {
    var results = std.ArrayList(Result).init(self.allocator);
    defer results.deinit();

    while (self.next_char()) |char| {
        switch (char) {
            ' ' => continue,
            '-' => if (self.next_char() == '-') {
                _ = self.next_char();
                try results.append(.{ .long_flag = self.read_argument() });
            } else {
                try results.append(.{ .short_flag = self.read_argument() });
            },
            '"' | '\'' => try results.append(.{ .string = self.read_string() }),
            else => try results.append(.{ .argument = self.read_argument() }),
        }
    }

    self.results = try results.toOwnedSlice();
}

fn next_char(self: *Lexer) ?u8 {
    if (self.pos >= self.input.len) return null;
    defer self.pos += 1;
    return self.input[self.pos];
}

fn read_argument(self: *Lexer) []const u8 {
    const start = self.pos - 1;
    while (self.next_char()) |char| {
        if (char == ' ') break;
    } else {
        return self.input[start..self.pos];
    }
    return self.input[start .. self.pos - 1];
}

fn read_string(self: *Lexer) []const u8 {
    const start = self.pos;
    const delim = self.input[start];
    var escape = false;

    while (self.next_char()) |char| {
        switch (char) {
            '\\' => escape = !escape,
            else => if (char == delim) {
                if (escape) {
                    escape = false;
                } else {
                    break;
                }
            } else {
                continue;
            },
        }
    }

    return self.input[start .. self.pos - 1];
}

test "basic argument parsing" {
    const allocator = std.testing.allocator;
    const expect = std.testing.expect;
    const expectEqualDeep = std.testing.expectEqualDeep;

    var lexer = Lexer.init(allocator, "foo bar --baz");
    defer lexer.deinit();
    try lexer.read();
    var results = lexer.results.?;

    try expect(results.len == 3);
    try expectEqualDeep(results[0], .{ .argument = "foo" });
    try expectEqualDeep(results[1], .{ .argument = "bar" });
    try expectEqualDeep(results[2], .{ .long_flag = "baz" });
}
