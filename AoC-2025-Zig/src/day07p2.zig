const std = @import("std");
const utils = @import("utils.zig");

pub fn main() !void {
    const filePath = "src/puzzle-inputs/day07";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const file_content = try utils.readFileContent(filePath, allocator);
    defer allocator.free(file_content);
    var lines_it = std.mem.splitScalar(u8, file_content, '\n');

    var rows = std.ArrayList([]u8){};
    var c_rows = std.ArrayList([]u64){};
    defer rows.deinit(allocator);
    defer c_rows.deinit(allocator);

    while (lines_it.next()) |line| {
        if (line.len == 0) continue;
        const row = try allocator.alloc(u8, line.len);
        const c_row = try allocator.alloc(u64, line.len);
        // Fill c_row with 0's
        @memset(c_row, 0);
        try c_rows.append(allocator, c_row);
        std.mem.copyForwards(u8, row, line);
        try rows.append(allocator, row);
    }
    defer {
        for (rows.items) |r| {
            allocator.free(r);
        }
    }
    defer {
        for (c_rows.items) |r| {
            allocator.free(r);
        }
    }
    const row_count = rows.items.len;
    const col_count = rows.items[0].len;
    for (0..col_count) |c| {
        const cell = rows.items[0][c];
        //std.debug.print("{c}", .{cell});
        if (cell == 'S') {
            rows.items[0][c] = '|';
            c_rows.items[0][c] = 1;
        }
    }
    for (1..row_count) |r| {
        const row = rows.items[r];
        for (0..col_count) |c| {
            if (row[c] == '^') {
                //std.debug.print("{c}", .{row[c]});
                continue;
            }
            const is_casc = rows.items[r - 1][c] == '|';
            const next_is_casc = col_count > c + 1 and rows.items[r - 1][c + 1] == '|';
            const is_split = col_count > c + 1 and rows.items[r][c + 1] == '^';
            if (is_split and next_is_casc) {
                rows.items[r][c] = '|';
                if (c + 2 < col_count) {
                    rows.items[r][c + 2] = '|';
                }
            }
            if (is_casc) {
                rows.items[r][c] = '|';
            }
            //const cell = row[c];
            //std.debug.print("{c}", .{cell});
        }
        //std.debug.print("\n", .{});
    }
    for (1..row_count) |r| {
        const row = rows.items[r];
        for (0..col_count) |c| {
            const cell = row[c];
            std.debug.print("{c}", .{cell});
            if (col_count > c + 1 and row[c + 1] == '^' and rows.items[r - 1][c + 1] == '|') {
                if (cell == '|') {
                    c_rows.items[r][c] += c_rows.items[r - 1][c + 1];
                }
                if (col_count > c + 2 and row[c + 2] == '|') {
                    c_rows.items[r][c + 2] += c_rows.items[r - 1][c + 1];
                }
            }
            if (cell == '|' and rows.items[r - 1][c] == '|') {
                c_rows.items[r][c] += c_rows.items[r - 1][c];
            }
        }
        std.debug.print("\n", .{});
    }
    //for (0..row_count) |r| {
    //    const row = c_rows.items[r];
    //    for (0..col_count) |c| {
    //        const cell = row[c];
    //        std.debug.print("{d}-", .{cell});
    //    }
    //    std.debug.print("\n", .{});
    //}

    const bottom_row = c_rows.items[row_count - 1];
    var total: usize = 0;
    for (0..col_count) |c| {
        total += bottom_row[c];
    }
    std.debug.print("Total paths: {d}\n", .{total});
    // ..S..
    // ..|..
    // .|^|.
    // |^|^|
}
