fn Node(comptime T: type) type {
    return struct {
        const Self = @This();

        data: T,
        head: ?*Self,
        tail: ?*Self,

        pub fn init(data: T) Self {
            return Self{ .data = data, .head = null, .tail = null };
        }
    };
}

pub fn LinkedList(comptime T: type) type {
    return struct {
        const Self = @This();

        len: usize,
        head: ?Node(T),

        pub fn init(data: T) Self {
            return Self{ .len = 1, .head = Node(T).init(data) };
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
