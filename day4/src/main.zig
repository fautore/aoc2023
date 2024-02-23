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

const Card = struct {
    winning: std.ArrayList(u8),
    numbers: std.ArrayList(u8),

    pub fn calculatePoints(self: *const Card) u32 {
        var cardPoints: u32 = 0;
        for (self.numbers.items) |n| {
            for (self.winning.items) |w| {
                if (n == w) {
                    if (cardPoints == 0) {
                        cardPoints = 1;
                    } else {
                        cardPoints = cardPoints * 2;
                    }
                }
            }
        }
        return cardPoints;
    }
};

pub fn parse(row: []const u8, rowIndex: u32) ?Card {
    _ = rowIndex;
    if (std.mem.indexOf(u8, row, ": ")) |indexOfSeparator| {
        const newRow = row[indexOfSeparator + 2 .. row.len];
        if (std.mem.indexOf(u8, newRow, " | ")) |indexOfWinningSeparator| {
            const winning = newRow[0..indexOfWinningSeparator];
            const numbers = newRow[indexOfWinningSeparator + 3 .. newRow.len];

            var winningList = std.ArrayList(u8).init(std.heap.page_allocator);
            var numbersList = std.ArrayList(u8).init(std.heap.page_allocator);

            var wIter = std.mem.tokenizeScalar(u8, winning, ' ');
            while (wIter.next()) |number| {
                const parsedNum = std.fmt.parseUnsigned(u8, number, 10) catch |err| {
                    std.debug.panic("{}", .{err});
                };
                winningList.append(parsedNum) catch |err| {
                    std.debug.print("{}", .{err});
                };
            }
            var nIter = std.mem.tokenizeScalar(u8, numbers, ' ');
            while (nIter.next()) |number| {
                const parsedNum = std.fmt.parseUnsigned(u8, number, 10) catch |err| {
                    std.debug.panic("{}", .{err});
                };
                numbersList.append(parsedNum) catch |err| {
                    std.debug.print("{}", .{err});
                };
            }
            const c = Card{ .winning = winningList, .numbers = numbersList };
            return c;
        } else {
            std.debug.panic("No winning separator!!!!!!", .{});
        }
    } else {
        return null;
    }
}

fn solvePart1(input: std.ArrayList(u8)) u32 {
    var solution: u32 = 0;
    var rowIter = std.mem.splitScalar(u8, input.items, '\n');
    var rowIndex: u32 = 0;
    while (rowIter.next()) |row| {
        defer rowIndex += 1;
        if (parse(row, rowIndex)) |c| {
            solution += c.calculatePoints();
        }
    }
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

// ------------------------------
// TESTS
//
//

test "test part 1" {
    const input =
        \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    ;
    const allocator = std.heap.page_allocator;
    var fileContents = std.ArrayList(u8).init(allocator);
    try fileContents.appendSlice(input);
    const solution = solvePart1(fileContents);
    std.testing.expect(solution == 13) catch |err| {
        std.debug.print("Test error: {} value: {} should be 13\n", .{ err, solution });
    };
}
test "test part 2" {
    const input =
        \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
        \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
        \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
        \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
        \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
        \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    ;
    const allocator = std.heap.page_allocator;
    var fileContents = std.ArrayList(u8).init(allocator);
    try fileContents.appendSlice(input);
    const solution = solvePart2(fileContents);
    std.testing.expect(solution == 467835) catch |err| {
        std.debug.print("Test error: {} value: {} should be 467835\n", .{ err, solution });
    };
}
