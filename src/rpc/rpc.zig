const std = @import("std");

pub fn encodeMessage(message: anytype) ![]u8 {
    const allocator = std.heap.page_allocator;
    var buffer = std.ArrayList(u8).init(allocator);

    try std.json.stringify(message, .{}, buffer.writer());

    return buffer.items;
}
