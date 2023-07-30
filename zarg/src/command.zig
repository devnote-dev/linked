const std = @import("std");

pub const Argument = struct {
    name: []const u8,
};

pub const Option = struct {
    pub const Type = enum {
        none,
        single,
        multiple,
    };

    long: []const u8,
    short: ?u8,
    type: Type,
};

pub const Command = struct {
    name: []const u8,
    commands: ?[]Command,
    arguments: ?[]Argument,
    options: ?[]Option,
};
