const std = @import("std");
const logger = @import("logger/logger.zig");
const lsp = @import("lsp.zig");

const Method = enum([]const u8) {
    Init = "initialize",
};

pub fn handleMessage(message: lsp.Request) !void {
    if (std.mem.eql(u8, message.method, "initialize")) try initialize(message.params);
}

fn initialize(params_value: std.json.Value) !void {
    const params = try std.json.parseFromValue(
        lsp.InitializeParams,
        std.heap.page_allocator,
        params_value,
        .{
            .ignore_unknown_fields = true,
        },
    );
    defer params.deinit();
    const message = try std.fmt.allocPrint(
        std.heap.page_allocator,
        "{any}",
        .{params.value.clientInfo},
    );

    try logger.println(message);
}
