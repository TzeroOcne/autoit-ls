const std = @import("std");
const logger = @import("./logger/logger.zig");

pub fn main() !void {
    try logger.init();
    try logger.println("Starting AutoIt Language Server");

    const stdin = std.io.getStdIn();
    var buf = std.io.bufferedReader(stdin.reader());
    const reader = buf.reader();

    var header_buffer: [1024]u8 = undefined;
    var header_stream = std.io.fixedBufferStream(&header_buffer);

    while (true) {
        const header: []const u8 = blk: {
            header_stream.reset();
            while (!std.mem.endsWith(u8, header_buffer[0..header_stream.pos], "\r\n\r\n")) {
                try reader.streamUntilDelimiter(header_stream.writer(), '\n', null);
                _ = try header_stream.write("\n");
            }
            break :blk header_buffer[0..header_stream.pos];
        };

        try logger.println(header);
    }

    try logger.println("Stopped AutoIt Language Server");
}

fn parseHeaders(bytes: []const u8) !struct { conteng_length: u32 } {
    var content_length: ?u32 = null;

    var lines = std.mem.splitScalar(u8, bytes, '\n');
    while (lines.next()) |line| {
        const trimmed = std.mem.trimRight(u8, line, &std.ascii.whitespace);
        if (trimmed.len == 0) continue;

        const colon = try std.mem.indexOfScalar(u8, trimmed, ':');

        const value = std.mem.trim(u8, trimmed[colon + 1 ..], &std.ascii.whitespace);

        content_length = try std.fmt.parseInt(u32, value, 10);
    }

    return .{
        .content_length = content_length orelse return error.MissingContentLength,
    };
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
