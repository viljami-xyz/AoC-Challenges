const std = @import("std");
const utils = @import("utils.zig");

const calculator = struct {
    operation: enum { Add, Multiply },
    value: i64,

    pub fn apply(self: *@This(), input: i64) i64 {
        switch (self.operation) {
            .Add => self.value += input,
            .Multiply => self.value *= input,
        }

        return self.value;
    }
};

fn onlyRealThings(line: []const u8, allocator: std.mem.Allocator) !std.ArrayList(calculator) {
    var calculators = std.ArrayList(calculator){};
    var parts = std.mem.splitScalar(u8, line, ' ');
    while (parts.next()) |part| {
        if (part.len == 0) continue;
        if (std.mem.eql(u8, part, "*")) {
            try calculators.append(allocator, .{ .operation = .Multiply, .value = 1 });
        } else if (std.mem.eql(u8, part, "+")) {
            try calculators.append(allocator, .{ .operation = .Add, .value = 0 });
        }
    }
    return calculators;
}

pub fn main() !void {
    const filePath = "src/puzzle-inputs/day06";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const file_content = try utils.readFileContent(filePath, allocator);
    defer allocator.free(file_content);
    var lines = std.mem.splitScalar(u8, file_content, '\n');
    var last: ?[]const u8 = null;
    // Do stuff
    while (lines.next()) |num_str| {
        if (lines.peek() == null) break;
        last = num_str;
    }
    const lastReal = last orelse return error.EmptyInput;
    std.debug.print("Last line: {s}\n", .{last orelse "null"});
    var calculators = onlyRealThings(lastReal, allocator) catch return error.InvalidCalculatorFormat;
    defer calculators.deinit(allocator);
    std.debug.print("Calculators found: {d}\n", .{calculators.items.len});

    var linesAgain = std.mem.splitScalar(u8, file_content, '\n');
    while (linesAgain.next()) |num_str| {
        var ix: usize = 0;
        var row = std.mem.splitScalar(u8, num_str, ' ');
        while (row.next()) |num_part| {
            if (num_part.len == 0) continue;
            if (std.mem.eql(u8, num_part, lastReal)) break;
            //const asNum = std.fmt.parseInt(i64, num_part, 10) catch continue;
            //std.debug.print("Raw num: {d}, ", .{asNum});
            //std.debug.print(" on index {d} ", .{ix});
            if (ix >= calculators.items.len) break;
            const value = std.fmt.parseInt(i64, num_part, 10) catch continue;
            _ = calculators.items[ix].apply(value);
            //std.debug.print("Calculatedd value {d}\n", .{new_value});
            ix += 1;
        }
    }
    var sum: i64 = 0;
    for (calculators.items) |calc| {
        std.debug.print("Calculator: {any}\n", .{calc.value});
        sum += calc.value;
    }
    std.debug.print("Sum of calculators: {d}\n", .{sum});
}
