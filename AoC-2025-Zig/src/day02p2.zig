const std = @import("std");

const Range = struct {
    start: i64,
    end: i64,
};

pub fn get_range(range_str: []const u8) !Range {
    var splitted = std.mem.splitScalar(u8, range_str, '-');
    const first = splitted.next() orelse return error.InvalidFormat;
    const last = splitted.next() orelse return error.InvalidFormat;
    return Range{
        .start = try std.fmt.parseInt(i64, first, 10),
        .end = try std.fmt.parseInt(i64, last, 10),
    };
}

fn allEqual(slice: [][]const u8) !bool {
    if (slice.len == 0) {
        return error.InvalidFormat;
    } else if (slice.len == 1) {
        return false;
    }

    const first = slice[0];
    for (slice[1..]) |v| {
        if (!std.mem.eql(u8, v,  first)) return false;
    }
    return true;
}

fn getChunks(N: u8, s: []const u8, allocator: std.mem.Allocator) ![][]const u8 {
    const len = s.len;
    const count = len / N;
    var result = try allocator.alloc([]const u8, count);

    var i: usize = 0;
    var idx: usize = 0;
    while (i < len) : (i += N) {
        result[idx] = s[i .. i + N];
        idx += 1;
    }

    //std.debug.print("Chunks: ", .{});
    //for (result) |chunk| {
    //    std.debug.print(" {s}", .{chunk});
    //}
    //std.debug.print("\n", .{});
    return result;
}

pub fn checkInvalidity(num: u64, allocator: std.mem.Allocator) !bool {
    var buf: [1024]u8 = undefined;
    const numAsStr = std.fmt.bufPrint(&buf, "{}", .{num}) catch return error.InvalidFormat;
    const numLen = numAsStr.len;
    const primeNums = [6]u8{ 2, 3, 5, 7, 11, 17 };
    for (primeNums) |prime| {
        if (numLen < prime) break;
        if (numLen % prime != 0) continue;
        //std.debug.print("Prime: {d}, numChar: {s}, numLen: {d}\n", .{prime, numAsStr, numLen});
        const chunkLenUsize = numLen / prime;
        const chunkLen: u8 = @intCast(chunkLenUsize);
        const chunks = getChunks(chunkLen, numAsStr, allocator) catch return error.InvalidFormat;
        defer allocator.free(chunks);
        if (try allEqual(chunks)) return true;
    }
    return false;
}

pub fn main() !void {
    const filePath = "src/puzzle-inputs/day02";
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const file_content = try readFileContent(filePath, allocator);
    defer allocator.free(file_content);
    var lines = std.mem.splitScalar(u8, file_content, ',');
    var invalidSum: u64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const chars = std.mem.trim(u8, line, &std.ascii.whitespace);
        const range = try get_range(chars);
        //std.debug.print("New range: {}\n", .{range});
        const start_usize: usize = @intCast(range.start);
        const end_usize: usize = @intCast(range.end + 1);
        for (start_usize..end_usize) |i| {
            //std.debug.print("{d}, ", .{i});
            if (try checkInvalidity(i, allocator)) {
                std.debug.print("Counthis this fucker in! {d}\n", .{i});
                invalidSum += i;
            }
            // print type of
            //const data_info = @typeInfo(@TypeOf(i));
            //std.debug.print("Type info: {any}\n", .{data_info});

        }
        //std.debug.print("{s}\n", .{""});
    }
    std.debug.print("Sum of invalid numbers: {d}\n", .{invalidSum});
}

pub fn readFileContent(path: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const file_size = try file.getEndPos();
    var buffer = try allocator.alloc(u8, file_size);
    const read_bytes = try file.readAll(buffer);
    return buffer[0..read_bytes];
}
