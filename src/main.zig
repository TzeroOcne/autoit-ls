const std = @import("std");
const rpc = @import("./rpc/rpc.zig");

pub fn main() void {
    const result = rpc.decodeMessage("Content-Length: 36\r\n\r\n{\"method\":\"textDocument/completion\"}") catch |err| {
        std.log.err("{!}", .{err});
        return;
    };
    std.log.debug("{any}\n", .{result});
}
