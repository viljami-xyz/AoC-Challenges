const std = @import("std");
const utils = @import("utils.zig");

const operations = enum {
    Add,
    Multiply,
};

const calculator = struct {
    operation: operations,
    value: i64,
    chars: [][]?u8,
    expected_length: usize,

    pub fn deinit(self: *@This(), allocator: std.mem.Allocator) void {
        for (self.chars) |row| {
            allocator.free(row);
        }
        allocator.free(self.chars);
    }

    pub fn init(
        allocator: std.mem.Allocator,
        operation_char: u8,
        col_len: usize,
        rows: usize,
    ) !calculator {
        const chars = try allocator.alloc([]?u8, rows);
        for (chars) |*row| {
            row.* = try allocator.alloc(?u8, col_len);
            @memset(row.*, null);
        }

        const operation: operations =
            if (operation_char == '*')
                .Multiply
            else if (operation_char == '+')
                .Add
            else
                return error.InvalidOperation;

        return .{
            .operation = operation,
            .value = if (operation == .Multiply) 1 else 0,
            .expected_length = col_len,
            .chars = chars,
        };
    }

    pub fn set_chars(self: *@This(), start_col: usize, file_cont: []const []const u8) !void {
        for (file_cont, 0..) |line, row_index| {
            const row = self.chars[row_index];
            for (start_col..start_col + self.expected_length) |col_index| {
                if (col_index >= line.len or line[col_index] == ' ') {
                    row[col_index - start_col] = null;
                } else {
                    row[col_index - start_col] = line[col_index];
                }
            }
            self.chars[row_index] = row;
        }
    }

    pub fn print_chars(self: *@This()) void {
        for (self.chars, 0..) |row, row_index| {
            std.debug.print("Row {d}: ", .{row_index});
            for (row) |c| {
                if (c) |char_val| {
                    std.debug.print("{c} ", .{char_val});
                } else {
                    std.debug.print("_ ", .{});
                }
            }
            std.debug.print("\n", .{});
        }
    }

    fn get_chars_as_numbers(self: *@This(), allocator: std.mem.Allocator) ![]i64 {
        const numbers = try allocator.alloc(i64, self.expected_length);
        @memset(numbers, 0);
        for (0..self.expected_length) |col_index| {
            for (self.chars) |row| {
                if (row[col_index]) |char_val| {
                    const as_num: i64 = char_val - '0';
                    numbers[col_index] = numbers[col_index] * 10 + as_num;
                }
            }
        }
        return numbers;
    }

    pub fn calculate(self: *@This(), allocator: std.mem.Allocator) i64 {
        const numbers = self.get_chars_as_numbers(allocator) catch return 0;
        defer allocator.free(numbers);
        for (numbers) |val| {
            switch (self.operation) {
                .Add => self.value += val,
                .Multiply => self.value *= val,
            }
        }
        return self.value;
    }
};

pub fn main() !void {
    const filePath = "src/puzzle-inputs/day06";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const file_content = try utils.readFileContent(filePath, allocator);
    defer allocator.free(file_content);
    var lines_it = std.mem.splitScalar(u8, file_content, '\n');

    var rows = std.ArrayList([]const u8){};
    defer rows.deinit(allocator);

    var max_row_len: usize = 0;
    while (lines_it.next()) |line| {
        if (line.len == 0) continue;
        if (line.len > max_row_len) {
            max_row_len = line.len;
        }
        try rows.append(allocator, line);
    }
    const last_row = rows.pop() orelse return;
    var operation = last_row[0];
    var col_len: usize = 0;
    var sum: i64 = 0;
    for (1..last_row.len) |i| {
        const is_operation = (last_row[i] == '*' or last_row[i] == '+');
        const is_last = (i == last_row.len - 1);
        if (is_operation) {
            var calc = try calculator.init(allocator, operation, col_len, rows.items.len);
            //std.debug.print("Initialized calculator with operation {c} and column length {d}\n", .{ operation, col_len });
            defer calc.deinit(allocator);
            const start_col = i - col_len - 1;
            calc.set_chars(start_col, rows.items) catch return;
            //calc.print_chars();
            const result = calc.calculate(allocator);
            sum += result;
            //std.debug.print("Calculator result: {d}\n", .{result});
            operation = last_row[i];
            col_len = 0;
            if (is_last) {
                col_len = max_row_len - last_row.len + 1;
                var last_calc = try calculator.init(allocator, operation, col_len, rows.items.len);
                //std.debug.print("Initialized last calculator with operation {c} and column length {d}\n", .{ operation, col_len });
                defer last_calc.deinit(allocator);
                last_calc.set_chars(last_row.len - 1, rows.items) catch return;
                const last_val = last_calc.calculate(allocator);
                sum += last_val;
                //std.debug.print("Last calculator result: {d}\n", .{last_calc.value});
                //last_calc.print_chars();
            }
        } else {
            col_len += 1;
        }
        //std.debug.print("Applying {c} to calculator\n", .{ i });
        //const item = rows.items[rows.items.len - 1][i];
        //std.debug.print("Applying {c} to calculator\n", .{ item });
    }
    std.debug.print("Final sum: {d}\n", .{sum});
}
