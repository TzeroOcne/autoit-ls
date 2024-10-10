const std = @import("std");

const RPCError = error{
    InvalidHeader,
};

const BaseMessage = struct {
    method: []u8,
};

const DecodeMessage = struct {
    method: []u8,
    content: []u8,
};

pub fn encodeMessage(content: anytype) ![]u8 {
    const allocator = std.heap.page_allocator;
    var buffer = std.ArrayList(u8).init(allocator);

    try std.json.stringify(content, .{}, buffer.writer());
    const message = try allocator.alloc(u8, buffer.items.len);
    std.mem.copyForwards(u8, message, buffer.items);
    buffer.clearAndFree();
    try std.fmt.format(buffer.writer(), "Content-Length: {}\r\n\r\n{s}", .{ message.len, message });
    const header = try allocator.alloc(u8, buffer.items.len);
    std.mem.copyForwards(u8, header, buffer.items);

    return header;
}

pub fn decodeMessage(message: []const u8) !DecodeMessage {
    const casted: []u8 = @constCast(message);
    const separator = std.mem.indexOf(u8, casted, "\r\n\r\n");
    if (separator == null) {
        return RPCError.InvalidHeader;
    }

    const result = casted[0..separator.?];

    const name = "Content-Length: ";
    const contentLengthByte = result[name.len..];
    const contentLength: usize = try std.fmt.parseUnsigned(usize, contentLengthByte, 10);

    const content = casted[(separator.? + 4)..][0..contentLength];
    const parsed = try std.json.parseFromSlice(
        BaseMessage,
        std.heap.page_allocator,
        content,
        .{},
    );
    const contentData = parsed.value;

    return .{
        .method = contentData.method,
        .content = content,
    };
}

test "Test Encode Message" {
    const allocator = std.heap.page_allocator;

    const input = .{ .testing = true }; // Input struct
    const expected_output = "Content-Length: 16\r\n\r\n{\"testing\":true}"; // Expected output

    const result = try encodeMessage(input);

    // Verify the result
    const result_str = result[0..];
    const expected_slice = expected_output[0..];

    // Check if the result matches the expected output
    try std.testing.expect(std.mem.eql(u8, result_str, expected_slice));

    // Cleanup
    allocator.free(result);
}

test "Test Decode Message" {
    const incoming_message = "Content-Length: 36\r\n\r\n{\"method\":\"textDocument/completion\"}";
    const result: DecodeMessage = try decodeMessage(incoming_message);
    const contentLength = result.content.len;
    try std.testing.expect(std.mem.eql(u8, result.method, "textDocument/completion"));
    try std.testing.expect(contentLength == 36);
}
