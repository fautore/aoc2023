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

const enginePartCharacters = [_]u8{ '*', '#', '+', '$' };
fn isEnginePart(character: u8) bool {
    for (enginePartCharacters) |enginePartCharacter| {
        if (enginePartCharacter == character) {
            return true;
        }
    }
    return false;
}

const EnginePart = struct { row: usize, column: usize };

const EnginePartNumber = struct {
    value: u32,
    row: usize,
    startColumn: usize,
    endColumn: usize,
    hasEnginePart: bool,

    pub fn belongsToEnginePart(self: *EnginePartNumber, enginePart: EnginePart) bool {
        std.debug.print("part: r:{} | sc:{} | ec:{}   engine: er:{} | ec:{}", .{ self.row, self.startColumn, self.endColumn, enginePart.row, enginePart.column });
        if (self.row >= applyOffset(enginePart.row, -1) and self.row <= applyOffset(enginePart.row, 1)) {
            if (enginePart.column >= applyOffset(self.startColumn, -1) and enginePart.column <= applyOffset(self.endColumn, 1)) {
                std.debug.print(" -> true\n", .{});
                return true;
            }
        }
        std.debug.print(" -> false\n", .{});
        return false;
    }
};

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

fn iterateRows(input: std.ArrayList(u8)) void {
    var engineParts = std.ArrayList(EnginePart).init(std.heap.page_allocator);
    var enginePartNumbers = std.ArrayList(EnginePartNumber).init(std.heap.page_allocator);

    var inputIterator = std.mem.splitScalar(u8, input.items, '\n');
    var i: usize = 0; // to iterate and keep track of the row number
    while (inputIterator.next()) |row| {
        defer i += 1;
        iterateRow(row, i, &engineParts, &enginePartNumbers);
    }
    for (enginePartNumbers.items) |epn| {
        std.debug.print("{} | {}\n", .{ epn.value, epn.hasEnginePart });
    }
}

fn iterateRow(row: []const u8, r: usize, engineParts: *std.ArrayList(EnginePart), enginePartNumbers: *std.ArrayList(EnginePartNumber)) void {
    var c: usize = 0;
    var currentNumberTempCharacterBuffer = std.ArrayList(u8).init(std.heap.page_allocator);
    var currentNumberStart: usize = 0;
    for (row) |character| {
        defer c += 1;
        if (character == '.') {
            if (currentNumberTempCharacterBuffer.items.len != 0) {
                const newPartValue = std.fmt.parseInt(u32, currentNumberTempCharacterBuffer.items, 10) catch |err| {
                    std.debug.panic("Error encountered while parsing int {}\nvalue {c}", .{ err, currentNumberTempCharacterBuffer.items });
                };
                var newPartNumber = EnginePartNumber{ .row = r, .startColumn = currentNumberStart, .endColumn = c - 1, .value = newPartValue, .hasEnginePart = false };
                for (engineParts.items) |enginePart| {
                    if (EnginePartNumber.belongsToEnginePart(&newPartNumber, enginePart)) {
                        newPartNumber.hasEnginePart = true;
                    }
                }
                enginePartNumbers.append(newPartNumber) catch |err| {
                    std.debug.panic("{}\n", .{err});
                };
            }
            currentNumberTempCharacterBuffer.clearAndFree();
            currentNumberStart = c + 1;
            continue;
        }
        if (isEnginePart(character)) {
            const newEnginePart = EnginePart{ .row = r, .column = c };
            engineParts.append(newEnginePart) catch |err| {
                std.debug.panic("{}\n", .{err});
            };
            for (enginePartNumbers.items) |*enginePartNumber| {
                if (EnginePartNumber.belongsToEnginePart(enginePartNumber, newEnginePart)) {
                    enginePartNumber.hasEnginePart = true;
                }
            }
            continue;
        }
        currentNumberTempCharacterBuffer.append(character) catch |err| {
            std.debug.panic("{}\n", .{err});
        };
    }
}

fn solvePart1(input: std.ArrayList(u8)) u32 {
    const solution: u32 = 0;
    iterateRows(input);
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
