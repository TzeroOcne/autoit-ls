const std = @import("std");

pub fn encodeMessage(message: anytype) void {
    var buf: [4096]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var string = std.ArrayList(u8).init(fba.allocator());
    std.json.stringify(message, .{}, string.writer()) catch {};
    std.log.info("{s}\n", .{string.items});
}
