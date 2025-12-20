const std = @import("std");
const utils = @import("utils.zig");

const Coordinate = struct {
    x: i64,
    y: i64,
};

const Rectangle = struct {
    nw: Coordinate,
    ne: Coordinate,
    se: Coordinate,
    sw: Coordinate,

    pub fn init(a: Coordinate, b: Coordinate) Rectangle {
        if ((a.y - a.x) > (b.y - b.x)) {
            return .{
                .nw = a,
                .ne = .{ .x = b.x, .y = a.y },
                .se = b,
                .sw = .{ .x = a.x, .y = b.y },
            };
        } else {
            return .{
                .nw = b,
                .ne = .{ .x = a.x, .y = b.y },
                .se = a,
                .sw = .{ .x = b.x, .y = a.y },
            };
        }
    }

    pub fn size(self: @This()) i64 {
        return (self.ne.x - self.nw.x + 1) * (self.sw.y - self.nw.y + 1);
    }
};

pub fn main() !void {
    const filePath = "src/puzzle-inputs/day09";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const file_content = try utils.readFileContent(filePath, allocator);
    defer allocator.free(file_content);
    var lines = std.mem.splitScalar(u8, file_content, '\n');
    var coordinates = std.ArrayList(Coordinate){};
    defer coordinates.deinit(allocator);
    // Do stuff
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var point = std.mem.splitScalar(u8, std.mem.trim(u8, line, "\r"), ',');
        const x_s = point.next() orelse return error.InvalidInput;
        const y_s = point.next() orelse return error.InvalidInput;
        const x = std.fmt.parseInt(i64, x_s, 10) catch {
            return error.InvalidInput;
        };
        const y = std.fmt.parseInt(i64, y_s, 10) catch {
            return error.InvalidInput;
        };
        try coordinates.append(allocator, .{ .x = x, .y = y });
    }

    var biggest_rectangle: ?Rectangle = null;
    var biggest_size: i64 = 0;
    for (coordinates.items, 0..) |coord, i| {
        if (i + 1 >= coordinates.items.len) break;
        for (coordinates.items[i + 1 ..]) |coord_b| {
            if (biggest_rectangle == null) {
                biggest_rectangle = Rectangle.init(coord, coord_b);
                continue;
            }
            const new_rect = Rectangle.init(coord, coord_b);
            const new_size = new_rect.size();
            if (new_size > biggest_size) {
                biggest_size = new_size;
                biggest_rectangle = new_rect;
            }
        }
    }
    std.debug.print("Biggest size of em all: {d}", .{biggest_size});
}
