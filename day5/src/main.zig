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

const MapEntry = struct {
    destination: u32,
    source: u32,
    range: u32,
};
fn parseAlmanacEntry(entry: []const u8) std.ArrayList(MapEntry) {
    var almanacEntryLines = std.mem.splitScalar(u8, entry, '\n');
    var almanacEntry = std.ArrayList(MapEntry).init(std.heap.page_allocator);
    while (almanacEntryLines.next()) |elem| {
        var digitsIterator = std.mem.tokenizeScalar(u8, elem, ' ');
        if (digitsIterator.next()) |firstDigitStr| {
            const firstDigit = std.fmt.parseUnsigned(u32, firstDigitStr, 10) catch |err| {
                std.debug.panic("{}", .{err});
            };
            if (digitsIterator.next()) |secondDigitStr| {
                const secondDigit = std.fmt.parseUnsigned(u32, secondDigitStr, 10) catch |err| {
                    std.debug.panic("{}", .{err});
                };
                if (digitsIterator.next()) |thirdDigitStr| {
                    const thirdDigit = std.fmt.parseUnsigned(u32, thirdDigitStr, 10) catch |err| {
                        std.debug.panic("{}", .{err});
                    };
                    almanacEntry.append(MapEntry{ .destination = firstDigit, .source = secondDigit, .range = thirdDigit }) catch |err| {
                        std.debug.panic("{}", .{err});
                    };
                }
            }
        }
    }
    return almanacEntry;
}

fn getAlmanacEntries(input: std.ArrayList(u8)) std.ArrayList(std.ArrayList(u8)) {
    var seeds = std.ArrayList(u32).init(std.heap.page_allocator);
    var seedToSoil: std.ArrayList(MapEntry);

    var almanacEntriesIterator = std.mem.splitSequence(u8, input.items, "\n\n");
    while (almanacEntriesIterator.next()) |almanacEntry| {
        std.debug.print("{s}\n", .{almanacEntry});
        if (std.mem.indexOf(u8, almanacEntry, ":")) |indexOfColumn| {
            if (std.mem.eql(u8, almanacEntry[indexOfColumn - 3 .. indexOfColumn], "map")) {
                if (std.mem.eql(u8, almanacEntry[0 .. indexOfColumn - 4], "seed-to-soil")) {
                    seedToSoil = parseAlmanacEntry(almanacEntry[indexOfColumn + 1 .. almanacEntry.len]);
                } else {
                    std.debug.print("{s}", .{almanacEntry[indexOfColumn + 1 .. almanacEntry.len]});
                }
            } else {
                if (std.mem.eql(u8, almanacEntry[0..indexOfColumn], "seeds")) {
                    const seedsCharacters = almanacEntry[indexOfColumn + 1 .. almanacEntry.len];
                    var seedsCharactersIterator = std.mem.tokenizeScalar(u8, seedsCharacters, ' ');
                    while (seedsCharactersIterator.next()) |seedCharacter| {
                        const seed = std.fmt.parseInt(u32, seedCharacter, 10) catch |err| {
                            std.debug.panic("{}", .{err});
                        };
                        seeds.append(seed) catch |err| {
                            std.debug.print("{}", .{err});
                        };
                    }
                }
            }
        }
    }
    std.debug.panic("", .{});
}

fn solvePart1(input: std.ArrayList(u8)) u32 {
    _ = getAlmanacEntries(input);
    return 0;
}

fn solvePart2(input: std.ArrayList(u8)) u32 {
    _ = input;
    return 0;
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

const testInput =
    \\seeds: 79 14 55 13
    \\
    \\seed-to-soil map:
    \\50 98 2
    \\52 50 48
    \\
    \\soil-to-fertilizer map:
    \\0 15 37
    \\37 52 2
    \\39 0 15
    \\
    \\fertilizer-to-water map:
    \\49 53 8
    \\0 11 42
    \\42 0 7
    \\57 7 4
    \\
    \\water-to-light map:
    \\88 18 7
    \\18 25 70
    \\
    \\light-to-temperature map:
    \\45 77 23
    \\81 45 19
    \\68 64 13
    \\
    \\temperature-to-humidity map:
    \\0 69 1
    \\1 0 69
    \\
    \\humidity-to-location map:
    \\60 56 37
    \\56 93 4
;

test "test part 1" {
    std.debug.print("\n", .{});
    const testSolution: u32 = 35;

    const allocator = std.heap.page_allocator;
    var fileContents = std.ArrayList(u8).init(allocator);
    try fileContents.appendSlice(testInput);
    const solution = solvePart1(fileContents);
    std.testing.expect(solution == testSolution) catch |err| {
        std.debug.panic("Test error: {} value: {} should be {}\n", .{ err, solution, testSolution });
    };
}
test "test part 2" {
    std.debug.print("\n", .{});
    const testSolution: u32 = 35;

    const allocator = std.heap.page_allocator;
    var fileContents = std.ArrayList(u8).init(allocator);
    try fileContents.appendSlice(testInput);
    const solution = solvePart2(fileContents);
    std.testing.expect(solution == testSolution) catch |err| {
        std.debug.panic("Test error: {} value: {} should be {}\n", .{ err, solution, testSolution });
    };
}
