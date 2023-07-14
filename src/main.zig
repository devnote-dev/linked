const std = @import("std");
const print = std.debug.print;
const LinkedList = @import("./linked.zig").LinkedList;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    var nums = try LinkedList(i32).init(&allocator, 2);
    defer nums.deinit();

    try nums.append(4);
    try nums.append(6);

    print("{d}\n", .{nums.len});
    print("{?}\n", .{try nums.index(0)});
}
