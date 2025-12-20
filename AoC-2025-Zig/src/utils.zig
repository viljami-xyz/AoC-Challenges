const std = @import("std");

pub fn readFileContent(
    path: []const u8,
    allocator: std.mem.Allocator,
) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    var buffer = try allocator.alloc(u8, file_size);

    const read_bytes = try file.readAll(buffer);
    return buffer[0..read_bytes];
}

pub fn containsChar(
    haystack: []const u8,
    needle: u8,
) bool {
    for (haystack) |c| {
        if (c == needle) {
            return true;
        }
    }
    return false;
}

pub fn getRangeAsList(
    range_str: []const u8,
    allocator: std.mem.Allocator,
) ![]usize {
    const dash_index = std.mem.indexOf(u8, range_str, "-") orelse
        return error.InvalidRangeFormat;
    const start_str = range_str[0..dash_index];
    const end_str = range_str[dash_index + 1..];
    const start = try std.fmt.parseInt(usize, start_str, 10);
    const end = try std.fmt.parseInt(usize, end_str, 10);
    if (end < start) return error.InvalidRangeFormat;

    const range_list = try allocator.alloc(usize, end - start + 1);

    for (start..end + 1, 0..) |i, ix| {
        range_list[ix] = i;
    }

    return range_list;
}



