const std = @import("std");
const builtin = @import("builtin");

pub const Config = struct {
    /// Whether to synchronize usage of this allocator.
    /// For actual thread safety, the backing allocator must also be thread safe.
    thread_safe: bool = !builtin.single_threaded,

    /// Whether to warn about leaked memory on deinit.
    /// This reporting is extremely limited; for proper leak checking use GeneralPurposeAllocator.
    report_leaks: bool = true,
};

pub fn BinnedAllocator(comptime config: Config) type {
    return struct {
        config: Config = config,

        const Self = @This();

        pub fn deinit(self: *Self) void {
            std.log.debug("{any}", .{self});
        }
    };
}
