const std = @import("std");
const time = @cImport({
    @cInclude("time.h");
});
var writer: ?std.fs.File.Writer = null;

const TimeError = error{
    FailedToGetTime,
};

pub fn init() !void {
    if (writer != null) return;
    const cwd = std.fs.cwd();
    const log_file_name = "logfile.txt";

    // Open the log file (create if it doesn't exist)
    const file = try cwd.createFile(log_file_name, .{});
    writer = file.writer();
}

pub fn println(message: []const u8) !void {
    const time_value = std.time.timestamp();
    const time_info = time.localtime(&time_value);

    // Buffer to hold the formatted date/time
    var current_time: [20]u8 = undefined;

    // Format time as "YYYY-MM-DD HH:MM:SS"
    const format = "%Y-%m-%d %H:%M:%S";
    const size = time.strftime(&current_time[0], current_time.len, format, time_info);

    if (size == 0) {
        return TimeError.FailedToGetTime;
    } else {
        try writer.?.print("[{s}]: {s}\n", .{ current_time[0 .. current_time.len - 1], message });
    }
}
