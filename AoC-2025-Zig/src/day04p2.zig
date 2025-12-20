const std = @import("std");
const utils = @import("utils.zig");

const Location = struct {
    row: usize,
    col: usize,
};

const Matrix = struct {
    data: [][]u8,
    rows: usize,
    cols: usize,

    pub fn init(
        allocator: std.mem.Allocator,
        rows: []const []const u8,
        removed_rolls: []Location,
    ) !Matrix {
        const row_len = rows.len;
        const col_len = rows[0].len;

        var data = try allocator.alloc([]u8, row_len);

        for (rows, 0..) |line, r_ix| {
            const row = try allocator.alloc(u8, col_len);
            std.mem.copyForwards(u8, row, line);
            for (removed_rolls) |roll| {
                if (roll.row == r_ix) {
                    row[roll.col] = '.';
                }
            }
            data[r_ix] = row;
        }

        return .{
            .data = data,
            .rows = row_len,
            .cols = col_len,
        };
    }

    fn isPaperRoll(
        self: @This(),
        row: usize,
        col: usize,
    ) bool {
        return self.data[row][col] == '@';
    }

    fn getAdjacentIndices(
        self: @This(),
        row: usize,
        col: usize,
    ) ![]Location {
        var adjacent = std.ArrayList(Location){};
        const directions = [_][2]isize{
            .{ -1, -1 }, // Up-Left
            .{ -1, 0 }, // Up
            .{ -1, 1 }, // Up-Right
            .{ 1, -1 }, // Down-Left
            .{ 1, 0 }, // Down
            .{ 1, 1 }, // Down-Right
            .{ 0, -1 }, // Left
            .{ 0, 1 }, // Right
        };
        const i_rows: isize = @intCast(self.rows);
        const i_cols: isize = @intCast(self.cols);
        for (directions) |dir| {
            const i_row: isize = @intCast(row);
            const i_col: isize = @intCast(col);
            const new_row = i_row + dir[0];
            const new_col = i_col + dir[1];
            if (new_row >= 0 and new_row < i_rows and
                new_col >= 0 and new_col < i_cols)
            {
                try adjacent.append(std.heap.page_allocator, .{
                    .row = @as(usize, @intCast(new_row)),
                    .col = @as(usize, @intCast(new_col)),
                });
            }
        }

        return adjacent.items;
    }

    pub fn getAdjacentPaperRollsCount(
        self: @This(),
        rows: usize,
        cols: usize,
    ) u8 {
        var count: u8 = 0;
        const adjacent = self.getAdjacentIndices(rows, cols) catch return 0;
        defer std.heap.page_allocator.free(adjacent);
        for (adjacent) |idx| {
            if (self.isPaperRoll(idx.row, idx.col)) {
                count += 1;
            }
        }

        return count;
    }

    pub fn at(self: @This(), row: usize, col: usize) u8 {
        return self.data[row][col];
    }

    pub fn deinit(self: @This(), allocator: std.mem.Allocator) void {
        for (self.data) |row| {
            allocator.free(row);
        }
        allocator.free(self.data);
    }
};

pub fn main() !void {
    const filePath = "src/puzzle-inputs/day04";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const file_content = try utils.readFileContent(filePath, allocator);
    defer allocator.free(file_content);

    var rows = std.ArrayList([]const u8){};
    defer rows.deinit(allocator);

    var lines = std.mem.splitScalar(u8, file_content, '\n');
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (trimmed.len == 0) continue;
        try rows.append(allocator, trimmed);
    }

    var removed_rolls = std.ArrayList(Location){};
    defer removed_rolls.deinit(allocator);
    var total_can_be_removed: u16 = 0;

    outer: while (true) {
        const matrix = try Matrix.init(allocator, rows.items, removed_rolls.items);
        defer matrix.deinit(allocator);
        var can_be_removed: u16 = 0;
        for (0..matrix.rows) |r| {
            for (0..matrix.cols) |c| {
                const paperRoll = matrix.isPaperRoll(r, c);
                if (paperRoll) {
                    const adjacent_count = matrix.getAdjacentPaperRollsCount(r, c);
                    if (adjacent_count < 4) {
                        can_be_removed += 1;
                        try removed_rolls.append(allocator, .{ .row = r, .col = c });
                    }
                }
            }
        }
        if (can_be_removed == 0) break :outer else {
            total_can_be_removed += can_be_removed;
        }
    }

    std.debug.print("Total paper rolls that can be removed: {}\n", .{total_can_be_removed});
}
