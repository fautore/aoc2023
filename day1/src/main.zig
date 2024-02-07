const std = @import("std");

fn readFile(allocator: std.mem.Allocator, filename: []const u8) !std.ArrayList([]u8) {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const stat = try file.stat();
    const buff = try file.readToEndAlloc(allocator, stat.size);
    defer allocator.free(buff);

    var lineIterator = std.mem.split(u8, buff, "\n");
    var lines = std.ArrayList([]u8).init(allocator);

    while (lineIterator.next()) |line| {
        const newLine = try allocator.dupe(u8, line);
        try lines.append(newLine);
    }
    return lines;
}

fn calculateRowValuePart1(row: []const u8) !u32 {
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
fn calculateRowValuePart2(allocator: std.mem.Allocator, row: []const u8) !u32 {
    var first: ?u8 = null;
    var last: ?u8 = null;
    const digitLiterals = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };
    const digitValues = [_]u8{ '1', '2', '3', '4', '5', '6', '7', '8', '9' };
    var characterBuffer = std.ArrayList(u8).init(allocator);
    for (row) |character| {
        if (std.ascii.isDigit(character)) {
            characterBuffer.clearAndFree();
            if (first == null) {
                first = character;
            }
            last = character;
        } else {
            try characterBuffer.append(character);
            for (digitLiterals, 0..) |digit, digitIndex| {
                //std.debug.print("\ncb: {s}, looking for: {s}", .{ characterBuffer.items, digit });
                if (std.mem.indexOf(u8, characterBuffer.items, digit) != null) {
                    if (first == null) {
                        first = digitValues[digitIndex];
                    }
                    last = digitValues[digitIndex];
                    characterBuffer.clearAndFree();
                    try characterBuffer.append(character);
                    break;
                }
            }
        }
    }
    if (first) |f| {
        if (last) |l| {
            std.debug.print(" f {c} l {c}", .{ f, l });
            const concatenatedDigits = [_]u8{ f, l };
            std.debug.print(" concatenatedDigits {s}", .{concatenatedDigits});
            return std.fmt.parseInt(u32, &concatenatedDigits, 10);
        }
    }
    return 0;
}

fn solvePart1(input: []const []const u8) !u32 {
    var total: u32 = 0;
    for (input) |row| {
        const rowValue = try calculateRowValuePart1(row);
        //std.debug.print("{s}: {}", .{ row, rowValue });
        total += rowValue;
    }
    //std.debug.print("\n", .{});
    return total;
}
fn solvePart2(input: []const []const u8) !u32 {
    var total: u32 = 0;
    const allocator = std.heap.page_allocator;
    for (input) |row| {
        std.debug.print("\nrow: {s}", .{row});
        const rowValue = try calculateRowValuePart2(allocator, row);
        std.debug.print(" val: {}", .{rowValue});
        total += rowValue;
    }
    return total;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const lines = try readFile(allocator, "input/input");
    defer lines.deinit();
    std.debug.print("part 1 total: {}\n", .{try solvePart1(lines.items)});
    std.debug.print("part 2 total: {}\n", .{try solvePart2(lines.items)});
}

test "test part 1" {
    const input = [_][]const u8{ "1abc2", "pqr3stu8vwx", "a1b2c3d4e5f", "treb7uchet" };
    try std.testing.expect(try solvePart1(&input) == 142);
}
test "test part 2" {
    const input = [_][]const u8{ "two1nine", "eightwothree", "abcone2threexyz", "xtwone3four", "4nineeightseven2", "zoneight234", "7pqrstsixteen" };
    try std.testing.expect(try solvePart2(&input) == 281);
}
