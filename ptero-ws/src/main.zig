const Socket = @This();
const std = @import("std");

allocator: std.mem.Allocator,
client: std.http.Client,
uri: std.Uri,
auth: []const u8,
id: []const u8,

pub fn init(args: struct { allocator: std.mem.Allocator, url: []const u8, key: []const u8, id: []const u8 }) !Socket {
    var client = std.http.Client{ .allocator = args.allocator };
    var uri = try std.Uri.parse(try std.fmt.allocPrint(args.allocator, "/api/client/servers/{s}/websocket", .{args.id}));
    var auth = try std.fmt.allocPrint(args.allocator, "Bearer {s}", .{args.key});

    return .{ .allocator = args.allocator, .client = client, .uri = uri, .auth = auth, .id = args.id };
}

pub fn deinit(self: *Socket) void {
    self.client.deinit();
}

pub const SocketAuth = struct { data: struct {
    socket: []const u8,
    token: []const u8,
} };

pub fn getAuthorization(self: *Socket) !SocketAuth {
    var headers = std.http.Headers{ .allocator = self.allocator };
    defer headers.deinit();

    try headers.append("Authorization", self.auth);
    try headers.append("Accept", "application/json");

    var req = self.client.request(.GET, self.uri, headers, .{});
    defer req.deinit();

    try req.start();
    try req.wait();

    const body = try req.reader().readAllAlloc(self.allocator, 512);
    defer self.allocator.free(body);

    const auth = try std.json.parseFromSlice(SocketAuth, self.allocator, body, .{});

    return auth.value.data;
}

// pub fn authorize(self: *Socket) !void {}

// pub fn connect(self: *Socket) !void {}

// pub fn disconnect(self: *Socket) void {}

// pub fn receive(self: *Socket) !Event {}
