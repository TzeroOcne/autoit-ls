const std = @import("std");

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();

    while (true) {
        const result = try stdin.readUntilDelimiterOrEofAlloc(std.heap.page_allocator, '\n', 1024);
        if (result == null) break;

        const line = result.?;
        defer std.heap.page_allocator.free(line);
        if (line.len == 0) break;

        // Do something with `line`
        std.debug.print("Read: {s}\n", .{line});
    }
}
