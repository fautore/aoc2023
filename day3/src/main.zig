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

fn calcRowSize(input: std.ArrayList(u8)) usize {
    var inputIterator = std.mem.splitScalar(u8, input.items, '\n');
    return inputIterator.first().len;
}

fn applyOffset(value: usize, offset: isize) usize {
    if (offset < 0) {
        const abs_offset: usize = @intCast(-offset);
        if (abs_offset > value) {
            return 0;
        }
        return value - abs_offset;
    } else {
        const abs_offset: usize = @intCast(offset);
        return value + abs_offset;
    }
}

fn peek(input: std.ArrayList(u8), row: usize, column: usize) ?u8 {
    const rowSize = calcRowSize(input);
    var character: ?u8 = null;
    character = input.items[row * rowSize + column];
    return character;
}

const Position = struct {
    row: isize,
    col: isize,
};

fn solvePart1(input: std.ArrayList(u8)) u32 {
    const solution: u32 = 0;

    var inputIterator = std.mem.splitScalar(u8, input.items, '\n');
    var rowIndex: usize = 0; // to iterate and keep track of the row number
    while (inputIterator.next()) |row| {
        defer rowIndex += 1;
        for (row, 0..) |c, columnIndex| {
            if (c == '*' or c == '#' or c == '+' or c == '$') {
                const positions: [8]Position = .{ Position{ .row = -1, .col = -1 }, Position{ .row = -1, .col = 0 }, Position{ .row = -1, .col = 1 }, Position{ .row = 0, .col = -1 }, Position{ .row = 0, .col = 1 }, Position{ .row = 1, .col = -1 }, Position{ .row = 1, .col = 0 }, Position{ .row = 1, .col = 1 } };
                for (positions) |p| {
                    const pRow = applyOffset(rowIndex, p.row);
                    const pCol = applyOffset(columnIndex, p.col);
                    if (peek(input, pRow, pCol)) |character| {
                        if (character != '.') {
                            std.debug.print("row: {}", .{pRow});
                            var startColumn = pCol;
                            var endColumn = pCol;
                            var prevCol = startColumn;
                            var nextCol = endColumn;
                            while (true) {
                                prevCol = applyOffset(prevCol, -1);
                                std.debug.print(" {}", .{prevCol});
                                if (prevCol == 0) {
                                    startColumn = prevCol;
                                    break;
                                }
                                if (peek(input, pRow, prevCol)) |charAtPrevCol| {
                                    std.debug.print(" {c}", .{charAtPrevCol});
                                    if (charAtPrevCol == '.' or charAtPrevCol == '*' or charAtPrevCol == '#' or charAtPrevCol == '+' or charAtPrevCol == '$') {
                                        break;
                                    }
                                }
                                startColumn = prevCol;
                            }
                            std.debug.print("start: {}", .{startColumn});
                            while (true) {
                                nextCol = applyOffset(nextCol, 1);
                                std.debug.print(" {}", .{nextCol});
                                if (nextCol == calcRowSize(input)) {
                                    endColumn = nextCol;
                                    break;
                                }
                                if (peek(input, pRow, nextCol)) |charAtNextCol| {
                                    std.debug.print(" {c}", .{charAtNextCol});
                                    if (charAtNextCol == '.' or charAtNextCol == '*' or charAtNextCol == '#' or charAtNextCol == '+' or charAtNextCol == '$') {
                                        break;
                                    }
                                }
                                endColumn = nextCol;
                            }
                            std.debug.print("end: {}\n", .{endColumn});
                        }
                    }
                }
            }
        }
    }
    std.debug.panic("panic to read stuff", .{});
    return solution;
}

fn solvePart2(input: std.ArrayList(u8)) u32 {
    _ = input;
    const solution: u32 = 0;
    return solution;
}

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
