const std = @import("std");
const utils = @import("utils.zig");

const min_dial: i32 = 0;
const max_dial: i32 = 99;

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

pub fn new_dial_pos(pos: *i32, move_to: i32) !i32 {
    const range = max_dial + 1;

    const start = @mod(pos.*, range);
    const end = @mod(pos.* + move_to, range);

    var hits: i32 = 0;

    std.debug.print("Current: {d}, moving to: {d}, calc-start: {d}, calc-end: {d}, ", .{pos.*, move_to, start, end});

    // Count landing on zero

    if (move_to > 0 and end < start) { // start 63, move_to 77, end = 40
        hits += @divTrunc(start+move_to, range);
    } else if (move_to < 0 and end > start) {
        hits += @divTrunc(-move_to+end, range);
        if (start == 0) hits -= 1;
    } else {
        if (move_to > 0)
            hits += @divTrunc(move_to, range)
        else
            hits += @divTrunc(-move_to, range);
            if (end == 0) hits += 1;
    }

    std.debug.print("hits: {d}\n", .{hits});
    pos.* = end;
    return hits;
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
        //std.debug.print("Line: {s}, ", .{chars});
        //std.debug.print("Before: {d}, ", .{start_dial});
        const through_zero = new_dial_pos(&start_dial, move) catch |err| {
            std.debug.print("Problem moving dial, {}\n", .{err});
            return;
        };
        //std.debug.print("Moving: {d}, ", .{move});
        //std.debug.print("Position now: {d}, ", .{start_dial});
        //std.debug.print("zero hits: {d}, ", .{through_zero});
        hit_zero += through_zero;
        //std.debug.print("Current hits: {d}\n", .{hit_zero});
    }
    std.debug.print("Number of zero hits: {d}\n", .{hit_zero});
}
