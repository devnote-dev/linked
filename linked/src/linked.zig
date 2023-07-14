const std = @import("std");

fn Node(comptime T: type) type {
    return struct {
        const Self = @This();

        data: T,
        head: ?*Self,
        tail: ?*Self,

        pub fn init(data: T) Self {
            return .{ .data = data, .head = null, .tail = null };
        }

        pub fn deinit(self: *Self, allocator: *std.mem.Allocator) void {
            if (self.tail) |tail| tail.deinit(allocator);
            allocator.destroy(self);
        }

        pub fn append(self: *Self, node: *Self) void {
            if (self.tail) |tail| {
                tail.append(node);
            } else {
                node.head = self;
                self.tail = node;
            }
        }

        pub fn index(self: *Self, pos: usize) ?Self {
            if (pos == 0) return self.*;
            if (self.tail) |tail| {
                return tail.index(pos - 1);
            } else {
                return null;
            }
        }
    };
}

pub const ListError = error{
    EmptyList,
    IndexOutOfBounds,
};

pub fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: *std.mem.Allocator,
        len: usize,
        head: ?*Node(T),

        pub fn init(allocator: *std.mem.Allocator, data: T) !Self {
            var node = try allocator.create(Node(T));
            node.* = Node(T).init(data);

            return .{ .allocator = allocator, .len = 1, .head = node };
        }

        pub fn deinit(self: *Self) void {
            if (self.head) |head| head.deinit(self.allocator);
        }

        pub fn append(self: *Self, data: T) !void {
            var node = try self.allocator.create(Node(T));
            node.* = Node(T).init(data);

            if (self.head) |head| {
                head.append(node);
            } else {
                self.head = node;
            }

            self.len += 1;
        }

        pub fn index(self: *Self, pos: usize) ListError!?T {
            if (pos > self.len - 1) return error.IndexOutOfBounds;
            if (self.head) |head| {
                if (head.index(pos)) |node| {
                    return node.data;
                } else {
                    return null;
                }
            } else {
                return error.EmptyList;
            }
        }

        pub fn pop(self: *Self) ListError!void {
            if (self.head) |head| {
                if (self.len == 1) {
                    head.deinit(self.allocator);
                    self.head = null;
                } else {
                    var node = head.index(self.len - 1).?;
                    node.head.?.tail = null;
                    node.deinit(self.allocator);
                }
                self.len -= 1;
            } else {
                return error.EmptyList;
            }
        }
    };
}

test "linked list" {
    const expect = @import("std").testing.expect;

    try expect(LinkedList(i32) == LinkedList(i32));

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    var nums = try LinkedList(i32).init(&allocator, 3);
    defer nums.deinit();

    try nums.pop();
    try expect(nums.len == 0);
    try expect(nums.pop() == error.EmptyList);

    try nums.append(4);
    try nums.append(6);

    try expect(nums.len == 3);

    var value = try nums.index(0);
    try expect(value != null);
    try expect(value.? == 2);

    value = try nums.index(1);
    try expect(value != null);
    try expect(value.? == 4);

    try expect(nums.index(3) == error.IndexOutOfBounds);
}
