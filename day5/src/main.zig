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

const AlmanacEntryType = enum { seed, soil, fertilizer, water, light, temperature, humidity, location };
fn parseEntryType(token: []const u8) AlmanacEntryType {
    // TODO: research how to do this with comptime
    if (std.mem.eql(u8, token, "seed")) {
        return AlmanacEntryType.seed;
    }
    if (std.mem.eql(u8, token, "soil")) {
        return AlmanacEntryType.soil;
    }
    if (std.mem.eql(u8, token, "fertilizer")) {
        return AlmanacEntryType.fertilizer;
    }
    if (std.mem.eql(u8, token, "water")) {
        return AlmanacEntryType.water;
    }
    if (std.mem.eql(u8, token, "light")) {
        return AlmanacEntryType.light;
    }
    if (std.mem.eql(u8, token, "temperature")) {
        return AlmanacEntryType.temperature;
    }
    if (std.mem.eql(u8, token, "humidity")) {
        return AlmanacEntryType.humidity;
    }
    if (std.mem.eql(u8, token, "location")) {
        return AlmanacEntryType.location;
    }
    std.debug.panic("token {any} is not a valid entry type\n", .{token});
}

fn getEntryDescriptor(entry: []const u8) struct { from: AlmanacEntryType, to: AlmanacEntryType } {
    var from: ?AlmanacEntryType = null;
    var to: ?AlmanacEntryType = null;

    if (std.mem.indexOf(u8, entry[0..entry.len], " map")) |indexOfMap| {
        const descriptor = if (std.mem.lastIndexOf(u8, entry[0..indexOfMap], "\n")) |indexOfNewLine| entry[indexOfNewLine + 1 .. indexOfMap] else entry[0..indexOfMap];
        var entryDescriptorTokens = std.mem.tokenizeSequence(u8, descriptor, "-to-");
        if (entryDescriptorTokens.next()) |fromToken| {
            std.debug.print("from token: {s}\n", .{fromToken});
            from = parseEntryType(fromToken);
        }
        if (entryDescriptorTokens.next()) |toToken| {
            std.debug.print("to token: {s}\n", .{toToken});
            to = parseEntryType(toToken);
        }
    } else std.debug.panic("no map", .{});
    if (from) |fromVal| {
        if (to) |toVal| {
            return .{ .from = fromVal, .to = toVal };
        } else std.debug.panic("to has no value in entry: {s}\n", .{entry});
    } else std.debug.panic("from has no value in entry: {s}\n", .{entry});
}

const MapEntry = struct {
    destination: u32,
    source: u32,
    range: u32,
};

const AlmanacEntry = struct {
    from: AlmanacEntryType,
    to: AlmanacEntryType,
    map: std.ArrayList(MapEntry),

    fn parse(entry: []const u8) AlmanacEntry {
        if (std.mem.indexOf(u8, entry, ":")) |indexOfColumn| {
            const entryDescriptor = getEntryDescriptor(entry[0..indexOfColumn]);

            var map = std.ArrayList(MapEntry).init(std.heap.page_allocator);
            var almanacEntryLines = std.mem.splitScalar(u8, entry[indexOfColumn + 2 .. entry.len], '\n');
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
                            map.append(MapEntry{ .destination = firstDigit, .source = secondDigit, .range = thirdDigit }) catch |err| {
                                std.debug.panic("{}", .{err});
                            };
                        }
                    }
                }
            }
            return AlmanacEntry{ .from = entryDescriptor.from, .to = entryDescriptor.to, .map = map };
        } else std.debug.panic("no column in enty {s}", .{entry});
    }
};

fn parseAlamanac(input: std.ArrayList(u8)) struct { seeds: std.ArrayList(u32), entries: std.ArrayList(AlmanacEntry) } {
    var seeds = std.ArrayList(u32).init(std.heap.page_allocator);
    var entries = std.ArrayList(AlmanacEntry).init(std.heap.page_allocator);

    if (std.mem.indexOf(u8, input.items, ":")) |indexOfColumn| {
        if (std.mem.eql(u8, input.items[0..indexOfColumn], "seeds")) {
            if (std.mem.indexOf(u8, input.items, "\n")) |indexOfNewLine| {
                const seedsCharacters = input.items[indexOfColumn + 1 .. indexOfNewLine];
                var seedsCharactersIterator = std.mem.tokenizeScalar(u8, seedsCharacters, ' ');
                while (seedsCharactersIterator.next()) |seedCharacter| {
                    const seed = std.fmt.parseInt(u32, seedCharacter, 10) catch |err| {
                        std.debug.panic("{}", .{err});
                    };
                    seeds.append(seed) catch |err| {
                        std.debug.print("{}", .{err});
                    };
                }
                if (std.mem.indexOf(u8, input.items, "\n")) |firstNewLineIndex| {
                    var almanacEntriesIterator = std.mem.splitSequence(u8, input.items[firstNewLineIndex + 1 .. input.items.len], "\n\n");
                    while (almanacEntriesIterator.next()) |almanacEntry| {
                        entries.append(AlmanacEntry.parse(almanacEntry)) catch |err| {
                            std.debug.panic("{}", .{err});
                        };
                    }
                    return .{ .seeds = seeds, .entries = entries };
                } else std.debug.panic("error eosdfasdfasdfasdf", .{});
            } else std.debug.panic("no newline after seeds found", .{});
        } else std.debug.panic("no seeds line found", .{});
    } else std.debug.panic("no ':' character found", .{});
}

fn walkAlmanac(values: std.ArrayList(u32), entries: std.ArrayList(AlmanacEntry), search: AlmanacEntryType) std.ArrayList(u32) {
    for (entries.items) |entry| {
        if (entry.from == search) {
            var ret = std.ArrayList(u32).init(std.heap.page_allocator);
            for (values.items) |v| {
                for (entry.map.items) |i| {
                    if (v >= i.source and v < i.source + i.range) {
                        ret.append(v - i.source + i.destination) catch |err| {
                            std.debug.panic("{}", .{err});
                        };
                    }
                }
            }
        }
    }
}

fn solvePart1(input: std.ArrayList(u8)) u32 {
    const almanac = parseAlamanac(input);
    _ = almanac;
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
