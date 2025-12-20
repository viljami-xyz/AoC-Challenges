const std = @import("std");
const utils = @import("utils.zig");

const joltageLen: usize = 12;

const JoltageCounter = struct {
    nums: [joltageLen]u8,
    chars: []const u8,

    pub fn init(chars: []const u8) JoltageCounter {
        return JoltageCounter{
            .nums = [_]u8{0} ** joltageLen,
            .chars = chars,
        };
    }

    pub fn printNums(self: @This()) void {
        for (self.nums) |n| {
            std.debug.print("{d}, ", .{n});
        }
        std.debug.print("\n", .{});
    }

    pub fn runJoltageCounter(self: *JoltageCounter) void {
        const target_len = joltageLen;
        const total_len = self.chars.len;
        var to_remove: usize = total_len - target_len;

        var out_len: usize = 0;

        for (self.chars) |c| {
            const digit: u8 = c - '0';

            while (out_len > 0 and
                self.nums[out_len - 1] < digit and
                to_remove > 0)
            {
                out_len -= 1;
                to_remove -= 1;
            }

            if (out_len < target_len) {
                self.nums[out_len] = digit;
                out_len += 1;
            } else {
                to_remove -= 1;
            }
        }
    }

    pub fn joltageListToInt(self: @This()) u64 {
        var joltageInt: u64 = 0;
        var multiplier: u64 = 1;
        for (self.nums, 0..) |_, ix| {
            const revIx = joltageLen - 1 - ix;
            const num = self.nums[revIx];
            joltageInt += @as(u64, num) * multiplier;
            multiplier *= 10;
        }
        return joltageInt;
    }
};

pub fn main() !void {
    const filePath = "src/puzzle-inputs/day03";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const file_content = try utils.readFileContent(filePath, allocator);
    defer allocator.free(file_content);
    var lines = std.mem.splitScalar(u8, file_content, '\n');
    var joltageSum: u64 = 0;
    while (lines.next()) |line| {
        const chars = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (chars.len == 0) continue;
        var joltageCounter = JoltageCounter.init(chars);
        joltageCounter.runJoltageCounter();
        const joltageInt = joltageCounter.joltageListToInt();
        joltageSum += joltageInt;
    }
    std.debug.print("Sum of invalid numbers: {d}\n", .{joltageSum});
}
