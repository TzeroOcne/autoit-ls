const rpc = @import("./rpc/rpc.zig");

pub fn main() !void {
    rpc.encodeMessage(.{ 1, 2 });
}
