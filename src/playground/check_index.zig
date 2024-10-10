const std = @import("std");

pub fn main() !void {
    std.log.debug("{any}", .{std.mem.indexOf(u8, "aaabbb", "bbb")});
}
