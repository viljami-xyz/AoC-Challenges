const std = @import("std");
const utils = @import("utils.zig");

const JunctionBox = struct {
    index: usize,
    x: i64,
    y: i64,
    z: i64,
    circuit: ?usize = null,

    pub fn print(self: @This()) void {
        std.debug.print("JunctionBox {d}: ({d}, {d}, {d}) Circuit: {any}\n", .{
            self.index,
            self.x,
            self.y,
            self.z,
            self.circuit,
        });
    }
};

fn distanceBetween(a: *JunctionBox, b: *JunctionBox) JunctionDistance {
    const dx = a.x - b.x;
    const dy = a.y - b.y;
    const dz = a.z - b.z;
    return .{ .box_a = a, .box_b = b, .distance = dx * dx + dy * dy + dz * dz };
}

const JunctionDistance = struct {
    box_a: *JunctionBox,
    box_b: *JunctionBox,
    distance: i64,
};

fn lessThan(context: void, a: JunctionDistance, b: JunctionDistance) bool {
    _ = context;
    return a.distance < b.distance;
}

fn areAllSameCircuit(junction_boxes: []JunctionBox) bool {
    const first_circuit = junction_boxes[0].circuit;
    if (first_circuit == null) {
        return false;
    }
    for (junction_boxes) |jb| {
        if (jb.circuit != first_circuit) {
            return false;
        }
    }
    return true;
}

pub fn main() !void {
    const filePath = "src/puzzle-inputs/day08";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const file_content = try utils.readFileContent(filePath, allocator);
    defer allocator.free(file_content);
    var lines = std.mem.splitScalar(u8, file_content, '\n');
    var junction_boxes = std.ArrayList(JunctionBox){};
    defer junction_boxes.deinit(allocator);
    var distances = std.ArrayList(JunctionDistance){};
    defer distances.deinit(allocator);
    var ix: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var parts = std.mem.splitScalar(u8, line, ',');
        var list_parts = std.ArrayList(i64){};
        defer list_parts.deinit(allocator);
        while (parts.next()) |part| {
            const parsed = std.fmt.parseInt(i64, part, 10) catch {
                return error.InvalidInput;
            };
            try list_parts.append(allocator, parsed);
        }
        const jb = JunctionBox{
            .index = ix,
            .x = list_parts.items[0],
            .y = list_parts.items[1],
            .z = list_parts.items[2],
        };
        try junction_boxes.append(allocator, jb);
        ix += 1;
    }
    for (junction_boxes.items, 0..) |*jb, jb_i| {
        if (jb_i + 1 >= junction_boxes.items.len) break;
        for (junction_boxes.items[jb_i + 1 ..]) |*other_jb| {
            const dist = distanceBetween(jb, other_jb);
            try distances.append(allocator, dist);
        }
    }
    std.mem.sort(JunctionDistance, distances.items, {}, lessThan);

    var second_last_a: JunctionBox = undefined;
    var second_last_b: JunctionBox = undefined;
    while (!areAllSameCircuit(junction_boxes.items)) {
        for (distances.items) |*dist| {
            if (dist.box_a.circuit != null and dist.box_b.circuit != null) {
                if (dist.box_a.circuit.? == dist.box_b.circuit.?) {
                    continue;
                }

                const from = dist.box_b.circuit.?;
                const to = dist.box_a.circuit.?;

                for (junction_boxes.items) |*jb| {
                    if (jb.circuit == from) {
                        jb.circuit = to;
                    }
                }

                continue;
            }
            if (dist.box_a.circuit == null and dist.box_b.circuit == null) {
                dist.box_a.circuit = dist.box_a.index;
                dist.box_b.circuit = dist.box_a.index;
            } else if (dist.box_a.circuit != null) {
                dist.box_b.circuit = dist.box_a.circuit;
            } else if (dist.box_b.circuit != null) {
                dist.box_a.circuit = dist.box_b.circuit;
            }
                second_last_a = dist.box_a.*;
                second_last_b = dist.box_b.*;
        }
    }
    std.debug.print("Last connected boxes:\n", .{});
    second_last_a.print();
    second_last_b.print();
    std.debug.print("Last two X's multiplied {d}", .{second_last_a.x * second_last_b.x});
}
