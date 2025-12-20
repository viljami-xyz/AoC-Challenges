const std = @import("std");
const utils = @import("utils.zig");

const Range = struct {
    start: usize,
    end: usize,
};

fn rangesOverlap(
    r1: Range,
    r2: Range,
) bool {
    return (r1.start <= r2.end and r1.end >= r2.start);
}

fn mergeRanges(
    r1: Range,
    r2: Range,
) Range {
    return Range{
        .start = if (r1.start < r2.start) r1.start else r2.start,
        .end = if (r1.end > r2.end) r1.end else r2.end,
    };
}

fn sumOfRanges(
    ranges: []const Range,
) usize {
    var sum: usize = 0;
    for (ranges) |range| {
        sum += range.end - range.start + 1;
    }
    return sum;
}

pub fn main() !void {
    const filePath = "src/puzzle-inputs/day05";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const file_content = try utils.readFileContent(filePath, allocator);
    defer allocator.free(file_content);
    var lines = std.mem.splitScalar(u8, file_content, '\n');
    var list_of_ranges = std.ArrayList(Range){};
    defer list_of_ranges.deinit(allocator);
    while (lines.next()) |line| {
        if (lines.peek() == null) break;
        if (utils.containsChar(line, '-')) {
            const dash = std.mem.indexOfScalar(u8, line, '-') orelse
                return error.InvalidRangeFormat;
            const start_str = line[0..dash];
            const end_str = line[dash + 1 ..];
            const start = try std.fmt.parseInt(usize, start_str, 10);
            const end = try std.fmt.parseInt(usize, end_str, 10);
            var vrange = Range{ .start = start, .end = end };
            for (list_of_ranges.items, 0..) |range, i| {
                if (rangesOverlap(range, vrange)) {
                    vrange = mergeRanges(range, vrange);
                    _ = list_of_ranges.orderedRemove(i);
                }
            }
            try list_of_ranges.append(allocator, vrange);
            //std.debug.print(" Contains -\n", .{});
        } else if (line.len == 0) {
            break;
            //std.debug.print(" Empty line\n", .{});
        }
    }
    var new_list_of_ranges = std.ArrayList(Range){};
    defer new_list_of_ranges.deinit(allocator);
    var marked_for_removal = std.AutoHashMap(usize, bool).init(allocator);
    defer marked_for_removal.deinit();
    for (list_of_ranges.items, 0..) |range, i| {
        if (marked_for_removal.get(i) != null) continue;
        var merged_range = range;
        for (list_of_ranges.items, 0..) |other_range, j| {
            if (i == j) continue;
            if (rangesOverlap(merged_range, other_range)) {
                //std.debug.print("Outer range index: {d}, Inner range index: {d}\n", .{ i, j });
                //std.debug.print(
                //    "Merging ranges: {d}-{d} and {d}-{d}\n",
                //    .{ merged_range.start, merged_range.end, other_range.start, other_range.end },
                //);
                merged_range = mergeRanges(merged_range, other_range);
                _ = try marked_for_removal.put(j, true);
            }
        }
        try new_list_of_ranges.append(allocator, merged_range);
    }
    for (new_list_of_ranges.items) |range| {
        std.debug.print("Range: {d}-{d}\n", .{ range.start, range.end });
    }
    std.debug.print("Fresh ingredients count: {d}\n", .{sumOfRanges(new_list_of_ranges.items)});
}
