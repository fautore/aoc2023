const std = @import("std");

fn readFile(allocator: std.mem.Allocator, filename: []const u8) !std.ArrayList(u8) {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const stat = try file.stat();
    const buff = try file.readToEndAlloc(allocator, stat.size);
    defer allocator.free(buff);

    var fileContents = std.ArrayList(u8).init(allocator);
    try fileContents.appendSlice(buff);
    return fileContents;
}

const EnginePart = struct {
    col: i32,
    row: i32,
};

fn solvePart1(input: std.ArrayList(u8)) u32 {
    const solution: u32 = 0;

    var inputIterator = std.mem.splitScalar(u8, input.items, '\n');
    var engineParts = std.ArrayList(EnginePart).init(std.heap.page_allocator);
    var rowIndex: usize = 0; // to iterate and keep track of the row number
    while (inputIterator.next()) |row| {
        defer rowIndex += 1;
        for (row, 0..) |c, columnIndex| {
            defer columnIndex += 1;
            if (c == '*' or c == '#' or c == '+' or c == '$') {
                engineParts.append(EnginePart{ .row = rowIndex, .col = columnIndex });
            }
        }
    }

    return solution;
}

fn solvePart2() void {}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var lines = try readFile(allocator, "input/input");
    defer lines.deinit();
    std.debug.print("part 1 total: {}\n", .{solvePart1(lines)});
    std.debug.print("part 2 total: {}\n", .{solvePart2(lines)});
}

test "test part 1" {
    const input =
        \\467..114..
        \\...*......
        \\..35..633.
        \\......#...
        \\617*......
        \\.....+.58.
        \\..592.....
        \\......755.
        \\...$.*....
        \\.664.598..
    ;
    const allocator = std.heap.page_allocator;
    var fileContents = std.ArrayList(u8).init(allocator);
    try fileContents.appendSlice(input);
    try std.testing.expect(solvePart1(fileContents) == 4361);
}
test "test part 2" {
    const input =
        \\467..114..
        \\...*......
        \\..35..633.
        \\......#...
        \\617*......
        \\.....+.58.
        \\..592.....
        \\......755.
        \\...$.*....
        \\.664.598..
    ;
    const allocator = std.heap.page_allocator;
    var fileContents = std.ArrayList(u8).init(allocator);
    try fileContents.appendSlice(input);
    try std.testing.expect(solvePart2(fileContents) == 2286);
}
