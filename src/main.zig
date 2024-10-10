const std = @import("std");
const logger = @import("./logger/logger.zig");

pub fn main() !void {
    try logger.init();
    try logger.println("Starting AutoIt Language Server");

    const stdin = std.io.getStdIn();
    var buf = std.io.bufferedReader(stdin.reader());
    var reader = buf.reader();
    var msg_buf: [8192]u8 = undefined;

    var message: []u8 = "";
    while (true) {
        const result = try reader.readUntilDelimiterOrEof(&msg_buf, '\n');
        if (result) |line| {
            try logger.println(line);
            message = try std.mem.concat(std.heap.page_allocator, u8, &[_][]const u8{ message, line });
            if (try isReady(message)) {
                message = "";
            }
        }
    }

    try logger.println("Stopped AutoIt Language Server");
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
