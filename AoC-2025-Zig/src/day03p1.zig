const std = @import("std");
const utils = @import("utils.zig");

pub fn main() !void {
    const filePath = "src/puzzle-inputs/day03";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const file_content = try utils.readFileContent(filePath, allocator);
    defer allocator.free(file_content);
    var lines = std.mem.splitScalar(u8, file_content, '\n');
    var joltageSum: u32 = 0;
    while (lines.next()) |line| {
        const chars = std.mem.trim(u8, line, &std.ascii.whitespace);
        var joltage = [2]u8{ 0, 0 };
        std.debug.print("Line: {s}", .{line});
        // Loop over chars
        for (chars, 0..) |c, ix| {
            const digit = c - '0';
            if (ix == 0) {
                joltage[0] = digit;
            } else {
                if (joltage[0] < @as(u8, digit) and ix != chars.len - 1) {
                    joltage[0] = digit;
                    joltage[1] = 0;
                } else if (joltage[1] < @as(u8, digit)) {
                    joltage[1] = digit;
                }
            }
            std.debug.print(" {d} ", .{digit});
        }
        const joltageInt = @as(u32, joltage[0]) * 10 + @as(u32, joltage[1]);
        joltageSum += joltageInt;
        std.debug.print(" => Joltage: {d}\n", .{joltageInt});
        std.debug.print("\n", .{});
    }
    std.debug.print("Sum of invalid numbers: {d}\n", .{joltageSum});
}
