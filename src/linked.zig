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
    };
}

test "linked list" {
    const expect = @import("std").testing.expect;

    try expect(LinkedList(i32) == LinkedList(i32));
}
