const std = @import("std");

pub const Request = struct {
    pub const Id = std.json.Value;

    jsonrpc: []const u8,
    method: []const u8,
    id: Id = .null,
    params: std.json.Value = .null,
};

pub const Response = struct {
    jsonrpc: []const u8 = "2.0",
    id: Request.Id,
    result: Result,

    pub const Result = union(enum) {
        success: JsonPreformatted,
    };
};

pub const JsonPreformatted = struct {
    raw: []const u8,
};

pub const Notification = struct {
    jsonrpc: []const u8,
    method: []const u8,
};

pub const InitializeParams = struct {
    clientInfo: ?struct {
        name: []const u8,
        version: ?[]const u8,
    },
};
