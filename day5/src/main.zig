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

const almanacEntriesType = enum {
    "seeds",
    "seedToSoil",
    "soilToFertilizer",
    "fertilizerToWater",
    "waterToLight",
    "lightToTemperature",
    "temperatureToHumidity",
    "humidityToLocation",
};

fn getAlmanacEntries(input: std.ArrayList(u8)) std.ArrayList(std.ArrayList(u8)) {
    var seeds = std.ArrayList(u32).init(std.heap.page_allocator);

    var almanacEntriesIterator = std.mem.splitSequence(u8, input.items, "\n\n");
    while (almanacEntriesIterator.next()) |almanacEntry| {
        std.debug.print("{s}\n", .{almanacEntry});
        if (std.mem.indexOf(u8, almanacEntry, ":")) | indexOfColumn | {
            if (almanacEntry[indexOfColumn - 3 .. indexOfColumn] == "map") {
                
            } else {
                if (almanacEntry[0..indexOfColumn] == "seeds") {
                    const seedsCharacters = almanacEntry[indexOfColumn + 1.. almanacEntry.len];     
                }
            }
        };
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
