const std = @import("std");
const rpc = @import("./rpc/rpc.zig");

pub fn main() void {
    const result = rpc.encodeMessage(.{ 1, 2 }) catch &[_]u8{};
    std.log.debug("{s}\n", .{result});
}
