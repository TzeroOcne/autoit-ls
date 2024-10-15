const std = @import("std");
const logger = @import("./logger/logger.zig");
const lsp = @import("lsp.zig");
const handler = @import("handler.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .stack_trace_frames = 8 }){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    try logger.init();
    try logger.println("Starting AutoIt Language Server");

    const stdin = std.io.getStdIn();
    var buf = std.io.bufferedReader(stdin.reader());
    const reader = buf.reader();

    var header_buffer: [1024]u8 = undefined;
    var header_stream = std.io.fixedBufferStream(&header_buffer);

    var content_buffer = std.ArrayList(u8).init(allocator);
    defer content_buffer.deinit();

    var parse_arena = std.heap.ArenaAllocator.init(allocator);
    defer parse_arena.deinit();

    const max_content_length = 4 << 20; // 4MB

    while (true) {
        const header = blk: {
            header_stream.reset();
            while (!std.mem.endsWith(u8, header_buffer[0..header_stream.pos], "\r\n\r\n")) {
                try reader.streamUntilDelimiter(header_stream.writer(), '\n', null);
                _ = try header_stream.write("\n");
            }
            break :blk try parseHeaders(header_buffer[0..header_stream.pos]);
        };

        const header_string = try std.fmt.allocPrint(std.heap.page_allocator, "Length: {}", .{header.content_length});
        try logger.println(header_string);

        const content = blk: {
            if (header.content_length > max_content_length) return error.MessageTooLong;
            try content_buffer.resize(header.content_length);
            const actual_length = try reader.readAll(content_buffer.items);
            if (actual_length < header.content_length) return error.UnexpectedEof;
            break :blk content_buffer.items;
        };
        try logger.println(content);

        const message = try std.json.parseFromSlice(
            lsp.Request,
            std.heap.page_allocator,
            content,
            .{},
        );

        try handler.handleMessage(message.value);
    }

    try logger.println("Stopped AutoIt Language Server");
}

fn parseHeaders(bytes: []const u8) !struct { content_length: u32 } {
    var content_length: ?u32 = null;

    var lines = std.mem.splitScalar(u8, bytes, '\n');
    while (lines.next()) |line| {
        const trimmed = std.mem.trimRight(u8, line, &std.ascii.whitespace);
        if (trimmed.len == 0) continue;

        const colon = std.mem.indexOfScalar(u8, trimmed, ':') orelse return error.InvalidHeader;

        const value = std.mem.trim(u8, trimmed[colon + 1 ..], &std.ascii.whitespace);

        content_length = try std.fmt.parseInt(u32, value, 10);
    }

    return .{
        .content_length = content_length orelse return error.MissingContentLength,
    };
}
