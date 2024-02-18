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

const EnginePart = struct {
    row: usize,
    column: usize,
    partNumbers: ?std.ArrayList(*EnginePartNumber),

    pub fn assignPartNumber(self: *EnginePart, enginePartNumber: *EnginePartNumber) void {
        if (self.partNumbers) |partNumbers| {
            partNumbers.append(&enginePartNumber) catch |err| {
                std.debug.panic("{}", .{err});
            };
        } else {
            self.partNumbers = std.ArrayList(*EnginePartNumber).init(std.heap.page_allocator);
            self.partNumbers.append(&enginePartNumber) catch |err| {
                std.debug.panic("{}", .{err});
            };
        }
    }
};
const enginePartCharacters = [_]u8{ '*', '#', '+', '$', '@', '&', '/', '=', '%', '-' };
fn isEnginePart(character: u8, filter: []const u8) bool {
    for (filter) |enginePartCharacter| {
        if (enginePartCharacter == character) {
            return true;
        }
    }
    return false;
}
fn findAllEngineParts(input: std.ArrayList(u8), filter: []const u8) std.ArrayList(EnginePart) {
    var engineParts = std.ArrayList(EnginePart).init(std.heap.page_allocator);

    var rowIterator = std.mem.splitScalar(u8, input.items, '\n');
    var rowIndex: usize = 0;
    while (rowIterator.next()) |row| {
        defer rowIndex += 1;
        for (row, 0..) |character, columnIndex| {
            if (isEnginePart(character, filter)) {
                const newEnginePart = EnginePart{ .row = rowIndex, .column = columnIndex, .partNumbers = std.ArrayList(*EnginePartNumber).init(std.heap.page_allocator) };
                engineParts.append(newEnginePart) catch |err| {
                    std.debug.panic("{}\n", .{err});
                };
            }
        }
    }
    return engineParts;
}

const EnginePartNumber = struct {
    value: u32,
    row: usize,
    startColumn: usize,
    endColumn: usize,
    hasEnginePart: bool,

    pub fn isNearEnginePart(self: *EnginePartNumber, enginePart: EnginePart) bool {
        if (applyOffset(self.row, -1) <= enginePart.row and applyOffset(self.row, 1) >= enginePart.row) {
            if (applyOffset(self.startColumn, -1) <= enginePart.column and applyOffset(self.endColumn, 1) >= enginePart.column) {
                return true;
            }
        }
        return false;
    }
};

fn createNewEnginePartNumber(characterBuffer: std.ArrayList(u8), row: usize, startColumn: usize, endColumn: usize, partNumberList: *std.ArrayList(EnginePartNumber)) EnginePartNumber {
    const newPartValue = std.fmt.parseInt(u32, characterBuffer.items, 10) catch |err| {
        std.debug.panic("Error encountered while parsing int {}\nvalue {c}", .{ err, characterBuffer.items });
    };
    const newPartNumber = EnginePartNumber{ .row = row, .startColumn = startColumn, .endColumn = endColumn, .value = newPartValue, .hasEnginePart = false };
    partNumberList.append(newPartNumber) catch |err| {
        std.debug.panic("{}\n", .{err});
    };
    return newPartNumber;
}

fn findAllEnginePartNumbers(input: std.ArrayList(u8)) std.ArrayList(EnginePartNumber) {
    var enginePartNumbers = std.ArrayList(EnginePartNumber).init(std.heap.page_allocator);

    var rowIterator = std.mem.splitScalar(u8, input.items, '\n');
    var rowIndex: usize = 0;
    while (rowIterator.next()) |row| {
        defer rowIndex += 1;
        var currentNumberTempCharacterBuffer = std.ArrayList(u8).init(std.heap.page_allocator);
        var currentNumberStartColumn: usize = 0;
        for (row, 0..) |character, columnIndex| {
            if (character != '.' and !isEnginePart(character, &enginePartCharacters)) {
                currentNumberTempCharacterBuffer.append(character) catch |err| {
                    std.debug.panic("{}\n", .{err});
                };
            }
            if (character == '.' or isEnginePart(character, &enginePartCharacters) or columnIndex + 1 == row.len) {
                if (currentNumberTempCharacterBuffer.items.len != 0) {
                    _ = createNewEnginePartNumber(currentNumberTempCharacterBuffer, rowIndex, currentNumberStartColumn, columnIndex - 1, &enginePartNumbers);
                    currentNumberTempCharacterBuffer.clearAndFree();
                }
                currentNumberStartColumn = columnIndex + 1;
            }
        }
    }
    return enginePartNumbers;
}

fn solvePart1(input: std.ArrayList(u8)) u32 {
    var solution: u32 = 0;
    var enginePartList = findAllEngineParts(input, &enginePartCharacters);
    var enginePartNumbers = findAllEnginePartNumbers(input);

    var i: usize = 0;
    while (i < enginePartNumbers.items.len) : (i += 1) {
        var partNumber = &enginePartNumbers.items[i];
        if (partNumber.hasEnginePart) {
            continue;
        }
        for (enginePartList.items, 0..) |enginePart, partIndex| {
            if (partNumber.isNearEnginePart(enginePart)) {
                partNumber.hasEnginePart = true;
                enginePartList.items[partIndex].assignPartNumber(partNumber);
                //std.debug.print("epn {}, ep: {}\n", .{ enginePartNumber, enginePart });
            }
            std.debug.print("{}", .{enginePart});
        }
        std.debug.print("epn:{}\n", .{partNumber});
        if (partNumber.hasEnginePart) {
            solution += partNumber.value;
        }
    }
    return solution;
}

fn solvePart2(input: std.ArrayList(u8)) u32 {
    var solution: u32 = 0;
    var enginePartList = findAllEngineParts(input, &[_]u8{'*'});
    var enginePartNumbers = findAllEnginePartNumbers(input);

    var i: usize = 0;
    while (i < enginePartNumbers.items.len) : (i += 1) {
        var partNumber = &enginePartNumbers.items[i];
        if (partNumber.hasEnginePart) {
            continue;
        }
        for (enginePartList.items, 0..) |enginePart, partIndex| {
            if (partNumber.isNearEnginePart(enginePart)) {
                partNumber.hasEnginePart = true;
                enginePartList.items[partIndex].assignPartNumber(partNumber);
                //std.debug.print("epn {}, ep: {}\n", .{ enginePartNumber, enginePart });
            }
            std.debug.print("{}", .{enginePart});
        }
        std.debug.print("epn:{}\n", .{partNumber});
        if (partNumber.hasEnginePart) {
            solution += partNumber.value;
        }
    }
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
        \\......#300
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
    const solution = solvePart1(fileContents);
    std.testing.expect(solution == 4661) catch |err| {
        std.debug.print("Test error: {} value: {} should be 4361\n", .{ err, solution });
    };
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
    const solution = solvePart2(fileContents);
    std.testing.expect(solution == 467835) catch |err| {
        std.debug.print("Test error: {} value: {} should be 4361\n", .{ err, solution });
    };
}
test "belongsToEnginePart => true" {
    var enginePartnumber = EnginePartNumber{ .row = 0, .startColumn = 3, .endColumn = 5, .value = 100, .hasEnginePart = false };
    const enginePart = EnginePart{ .row = 0, .column = 2, .partNumbers = null };
    const result = enginePartnumber.isNearEnginePart(enginePart);
    try std.testing.expect(result);
}
test "belongsToEnginePart => false" {
    var enginePartnumber = EnginePartNumber{ .row = 0, .startColumn = 3, .endColumn = 5, .value = 100, .hasEnginePart = false };
    const enginePart = EnginePart{ .row = 0, .column = 10, .partNumbers = null };
    const result = enginePartnumber.isNearEnginePart(enginePart);
    try std.testing.expect(result == false);
}
