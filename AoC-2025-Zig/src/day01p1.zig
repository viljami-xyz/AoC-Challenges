const std = @import("std");
const utils = @import("utils.zig");

const min_dial: i8 = 0;
const max_dial: i8 = 99;

const CharError = error{
    InvalidFormat,
    InvalidCharacter,
    Overflow,
};

pub fn move_dial(char_line: []const u8) CharError!i32 {
    if (char_line.len < 2) return CharError.InvalidFormat;
    const direction = char_line[0];
    const num_slice = char_line[1..];
    const value = try std.fmt.parseInt(i32, num_slice, 10);
    return switch (direction) {
        'L' => -value,
        'R' => value,
        else => CharError.InvalidFormat,
    };
}

pub fn new_dial_pos(pos: *i32, move_to: i32) !void {
    pos.* += move_to;
    while (!(pos.* >= min_dial and pos.* <= max_dial)) {
        if (pos.* > max_dial) {
            pos.* = pos.*-(max_dial+1); // 0 + (121 - 99)
        } else if (pos.* < min_dial) {
            pos.* = max_dial+1 - (min_dial - pos.*); // 99 - (0 + 14)
        }
    }
}

pub fn main() !void {
    //    var gpa = std.heap.GeneralPurposeAllocator(.{.thread_safe = true}){};
    //    defer if (gpa.deinit() == .leak) {
    //        std.log.err("GeneralPurposeAllocator leaked memory\n", .{});
    //    };
    const filePath = "src/puzzle-inputs/day01";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const file_content = try utils.readFileContent(filePath, allocator);
    defer allocator.free(file_content);
    var lines = std.mem.splitScalar(u8, file_content, '\n');
    var start_dial: i32 = 50;
    var hit_zero: i32 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const chars = std.mem.trim(u8, line, " ");
        const move = move_dial(chars) catch |err| {
            std.debug.print("Invalid line, {}\n", .{err});
            continue;
        };
        std.debug.print("Line: {s}, ", .{chars});
        std.debug.print("Before: {d}, ", .{start_dial});
        try new_dial_pos(&start_dial, move);
        std.debug.print("Moving: {d}, ", .{move});
        std.debug.print("Position now: {d}\n", .{start_dial});
        if (start_dial == 0) {
            hit_zero += 1;
        }
    }
    std.debug.print("Number of zero hits: {d}\n", .{hit_zero});
}
