const std = @import("std");
const logger = @import("logger/logger.zig");
const lsp = @import("lsp.zig");

const Method = enum([]const u8) {
    Init = "initialize",
};

pub fn handleMessage(message: lsp.Request) !void {
    if (std.mem.eql(u8, message.method, "initialize")) try initialize();
}

fn initialize() !void {
    try logger.println("Handle Init.");
}
