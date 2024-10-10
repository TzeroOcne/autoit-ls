const std = @import("std");
const logger = @import("./logger/logger.zig");

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    try logger.init();

    var message: []u8 = "";
    while (true) {
        const result = try stdin.readUntilDelimiterOrEofAlloc(std.heap.page_allocator, '\n', 1024);
        if (result == null) break;

        const line = result.?;
        message = try std.mem.concat(std.heap.page_allocator, u8, &[_][]const u8{ message, line });
        try logger.println(line);
        if (try isReady(message)) {
            message = "";
        }
        defer std.heap.page_allocator.free(line);
        if (line.len == 0) break;
    }
}

fn isReady(message: []const u8) !bool {
    const casted: []u8 = @constCast(message);
    const separator = std.mem.indexOf(u8, casted, "\r\n\r\n");
    if (separator == null) {
        return false;
    }

    const result = casted[0..separator.?];

    const name = "Content-Length: ";
    const contentLengthByte = result[name.len..];
    const contentLength: usize = try std.fmt.parseUnsigned(usize, contentLengthByte, 10);
    const content = casted[(separator.? + 4)..][0..contentLength];

    if (content.len < contentLength) {
        return false;
    }

    return true;
}
