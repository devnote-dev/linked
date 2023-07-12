const print = @import("std").debug.print;

pub fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            data: T,
            head: ?*Node,
            tail: ?*Node,
        };

        len: usize,
        head: ?*Node,

        pub fn index(self: *Self, pos: usize) ?T {
            if (pos < 0 or pos > self.len - 1 or self.head == null) return null;
            if (pos == 0) return self.head.?.data;

            var node = self.head.?;
            var i: usize = 0;
            while (i <= pos) {
                print("\ni: {}\n", .{i});
                node = node.tail.?;
                i += 1;
            }

            return node.data;
        }

        pub fn append(self: *Self, data: T) void {
            if (self.head) |head| {
                var node = head;
                while (node.tail != null) {
                    node = node.tail.?;
                }

                node.tail = &Node{
                    .data = data,
                    .head = node,
                    .tail = null,
                };
            } else {
                self.head = &Node{
                    .data = data,
                    .head = null,
                    .tail = null,
                };
            }

            self.len += 1;
        }
    };
}

test "linked list" {
    const expect = @import("std").testing.expect;

    try expect(LinkedList(i32) == LinkedList(i32));

    var nums = LinkedList(i32){
        .head = null,
        .len = 0,
    };

    nums.append(2);
    nums.append(4);
    nums.append(6);

    try expect(nums.len == 3);

    var value = nums.index(0);
    try expect(value != null);
    try expect(value.? == 2);

    value = nums.index(1);
    try expect(value != null);
    try expect(value.? == 4);

    try expect(nums.index(3) == null);
}
