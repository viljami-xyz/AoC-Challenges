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

    var max_connections: usize = 1000;
    for (distances.items) |*dist| {
        if (max_connections == 0) {
            break;
        }
        max_connections -= 1;
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
    }

    var map = std.AutoHashMap(usize, usize).init(allocator);
    defer map.deinit();
    for (junction_boxes.items) |jb| {
        if (jb.circuit) |circuit| {
            jb.print();
            if (!map.contains(circuit)) {
                try map.put(circuit, 1);
            } else {
                map.put(circuit, map.get(circuit).? + 1) catch {};
            }
        }
    }
    var map_iter = map.iterator();
    while (map_iter.next()) |entry| {
        const key = entry.key_ptr.*;
        const value = entry.value_ptr.*;
        std.debug.print("Circuit {d} has {d} junction boxes connected.\n", .{ key, value });
    }
    var biggest_three: [3]usize = .{ 0, 0, 0 };
    var iter = map.iterator();
    while (iter.next()) |entry| {
        const count = entry.value_ptr.*;
        if (count > biggest_three[0]) {
            biggest_three[2] = biggest_three[1];
            biggest_three[1] = biggest_three[0];
            biggest_three[0] = count;
        } else if (count > biggest_three[1]) {
            biggest_three[2] = biggest_three[1];
            biggest_three[1] = count;
        } else if (count > biggest_three[2]) {
            biggest_three[2] = count;
        }
    }
    std.debug.print("Top three biggest circuits: {d}, {d}, {d}\n", .{
        biggest_three[0],
        biggest_three[1],
        biggest_three[2],
    });
    std.debug.print("As Multiplied: {d}\n", .{
        biggest_three[0] * biggest_three[1] * biggest_three[2],
    });
}
