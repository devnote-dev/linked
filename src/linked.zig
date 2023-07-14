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
            if (self.head) |head| allocator.destroy(head);
            if (self.tail) |tail| allocator.destroy(tail);
            allocator.destroy(self);
        }
    };
}

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
    };
}

// test "linked list" {
//     const expect = @import("std").testing.expect;

//     try expect(LinkedList(i32) == LinkedList(i32));

//     var nums = LinkedList(i32){
//         .head = null,
//         .len = 0,
//     };

//     nums.append(2);
//     nums.append(4);
//     nums.append(6);

//     try expect(nums.len == 3);

//     var value = nums.index(0);
//     try expect(value != null);
//     try expect(value.? == 2);

//     value = nums.index(1);
//     try expect(value != null);
//     try expect(value.? == 4);

//     try expect(nums.index(3) == null);
// }
