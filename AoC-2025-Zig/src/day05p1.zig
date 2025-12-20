const std = @import("std");
const utils = @import("utils.zig");

const Range = struct {
    start: usize,
    end: usize,
};

pub fn main() !void {
    const filePath = "src/puzzle-inputs/day05-sample";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const file_content = try utils.readFileContent(filePath, allocator);
    defer allocator.free(file_content);
    var lines = std.mem.splitScalar(u8, file_content, '\n');
    var list_of_ranges = std.ArrayList(Range){};
    defer list_of_ranges.deinit(allocator);
    var fresh_ingredients: u16 = 0;
    while (lines.next()) |line| {
        if (lines.peek() == null) break;
        if (utils.containsChar(line, '-')) {
            const dash = std.mem.indexOfScalar(u8, line, '-') orelse
                return error.InvalidRangeFormat;
            const start_str = line[0..dash];
            const end_str = line[dash + 1 ..];
            const start = try std.fmt.parseInt(usize, start_str, 10);
            const end = try std.fmt.parseInt(usize, end_str, 10);
            try list_of_ranges.append(allocator, .{ .start = start, .end = end });
            //std.debug.print(" Contains -\n", .{});
        } else if (line.len == 0) {
            continue;
            //std.debug.print(" Empty line\n", .{});
        } else {
            //std.debug.print(" Just a number\n", .{});
            const num = try std.fmt.parseInt(usize, line, 10);
            for (list_of_ranges.items) |range| {
                if (num >= range.start and num <= range.end) {
                    fresh_ingredients += 1;
                    break;
                }
            }
        }
    }
    std.debug.print("Fresh ingredients count: {d}\n", .{fresh_ingredients});
}
