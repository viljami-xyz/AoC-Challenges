const std = @import("std");
const utils = @import("utils.zig");

pub fn main() !void {
    const filePath = "src/puzzle-inputs/day03";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const file_content = try utils.readFileContent(filePath, allocator);
    defer allocator.free(file_content);
    var lines = std.mem.splitScalar(u8, file_content, '\n');
    // Do stuff
    lines.next();
}
