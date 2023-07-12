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
}
