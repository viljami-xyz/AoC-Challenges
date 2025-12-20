const std = @import("std");
const utils = @import("utils.zig");

const Range = struct {
    start: i64,
    end: i64,
};

pub fn get_range(range_str: []const u8) !Range {
    var splitted = std.mem.splitScalar(u8, range_str, '-');
    const first = splitted.next() orelse return error.InvalidFormat;
    const last = splitted.next() orelse return error.InvalidFormat;
    return Range{
        .start = try std.fmt.parseInt(i64, first, 10),
        .end = try std.fmt.parseInt(i64, last, 10),
    };
}

pub fn checkInvalidity(num: u64) !bool {
    var buf: [1024]u8 = undefined;
    const numAsStr = std.fmt.bufPrint(&buf, "{}", .{num}) catch return error.InvalidFormat;
    const numLen = numAsStr.len;
    if (numLen % 2 == 1) {
        std.debug.print("Dawg, not possible, {s}\n", .{numAsStr});
        return false;
    }
    const firstPart = numAsStr[0..numLen/2];
    const secondPart = numAsStr[numLen/2..];
    std.debug.print("Checking number: {s} - {s}\n", .{firstPart, secondPart});
    return std.mem.eql(u8, firstPart, secondPart);
}

pub fn main() !void {
    const filePath = "src/puzzle-inputs/day02-sample";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const file_content = try utils.readFileContent(filePath, allocator);
    defer allocator.free(file_content);
    var lines = std.mem.splitScalar(u8, file_content, ',');
    var invalidSum: u64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const chars = std.mem.trim(u8, line, &std.ascii.whitespace);
        const range = try get_range(chars);
        std.debug.print("New range: {}\n", .{range});
        const start_usize: usize = @intCast(range.start);
        const end_usize: usize = @intCast(range.end + 1);
        for (start_usize..end_usize) |i| {
            std.debug.print("{d}, ", .{i});
            if (try checkInvalidity(i)) {
                std.debug.print("Counthis this fucker in! {d}\n", .{i});
                invalidSum+=i;
            }
            // print type of
            //const data_info = @typeInfo(@TypeOf(i));
            //std.debug.print("Type info: {any}\n", .{data_info});

        }
        std.debug.print("{s}\n", .{""});
    }
    std.debug.print("Sum of invalid numbers: {d}\n", .{invalidSum});
}
