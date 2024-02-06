const std = @import("std");

fn readFile(allocator: std.mem.Allocator, filename: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const stat = try file.stat();
    const buff = try file.readToEndAlloc(allocator, stat.size);
    return buff;
}

pub fn calculateRowValue(row: []const u8) !u32 {
    var first: ?u8 = null;
    var last: ?u8 = null;

    for (row) |character| {
        if (std.ascii.isDigit(character)) {
            if (first == null) {
                first = character;
            }
            last = character;
        }
    }
    if (first) |f| {
        if (last) |l| {
            //std.debug.print("\n f {c} l {c}", .{ f, l });
            const concatenatedDigits = [_]u8{ f, l };
            //std.debug.print(" concatenatedDigits {s}", .{concatenatedDigits});
            return std.fmt.parseInt(u32, &concatenatedDigits, 10);
        }
    }
    return 0;
}

pub fn calculateValues(input: []const []const u8) !u32 {
    var total: u32 = 0;
    for (input) |row| {
        const rowValue = try calculateRowValue(row);
        //std.debug.print("{s}: {}", .{ row, rowValue });
        total += rowValue;
    }
    //std.debug.print("\n", .{});
    return total;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const buff = try readFile(allocator, "input");
    defer allocator.free(buff);

    var lineIterator = std.mem.split(u8, buff, "\n");
    var lines = std.ArrayList([]u8).init(allocator);
    defer lines.deinit();

    while (lineIterator.next()) |line| {
        const newLine = try allocator.dupe(u8, line);
        try lines.append(newLine);
    }
    std.debug.print("total: {}\n", .{try calculateValues(lines.items)});
}
test "simple test" {
    const input = [_][]const u8{ "1abc2", "pqr3stu8vwx", "a1b2c3d4e5f", "treb7uchet" };
    try std.testing.expect(try calculateValues(&input) == 142);
}
