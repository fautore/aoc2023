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

const Draw = struct {
    red: ?u16,
    green: ?u16,
    blue: ?u16,
};

fn parseDraw(drawStr: []u8) Draw {
    const drawStrIter = std.mem.splitSequence(u8, drawStr, ", ");
    var draw = Draw{};
    while (drawStrIter.next()) |dice| {
        const diceIter = std.mem.splitSequence(u8, dice, " ");
        const value = diceIter.next() catch |err| {
            _ = err;
        };
        const parsedValue = std.fmt.parseInt(u16, value, 10) catch |err| {
            std.debug.print("err", .{err});
        };
        const color = diceIter.next() catch |err| {
            _ = err;
        };
        if (std.mem.eql(u8, color, "red")) {
            draw.red = parsedValue;
        } else if (std.mem.eql(u8, color, "green")) {
            draw.green = parsedValue;
        } else if (std.mem.eql(u8, color, "blue")) {
            draw.blue = parsedValue;
        }
    }
    return draw;
}

const Game = struct {
    Id: u32,
    first_draw: Draw,
    second_draw: Draw,
    third_draw: Draw,
};

fn solvePart1(input: std.ArrayList(u8)) u32 {
    const solution: u32 = 0;

    var linesIter = std.mem.splitScalar(u8, input.items, '\n');
    var games = std.ArrayList(Game).init(std.heap.page_allocator);
    while (linesIter.next()) |row| {
        std.debug.print("\n{s}", .{row});
        var lineIter = std.mem.splitSequence(u8, row, ": ");
        const gameStr = lineIter.first();
        var gameTokenizer = std.mem.tokenizeSequence(u8, gameStr, "Game ");
        if (gameTokenizer.peek()) |gameIdStr| {
            std.debug.print("gameId: {s}", .{gameIdStr});
            if (std.fmt.parseInt(u32, gameIdStr, 10)) |gameId| {
                if (lineIter.peek()) |gameCubes| {
                    var gameStrIter = std.mem.splitSequence(u8, gameCubes, "; ");
                    const first_draw: Draw = parseDraw(gameStrIter.next()) catch |err| {
                        std.debug.print("{}", .{err});
                    };
                    const second_draw: Draw = parseDraw(gameStrIter.next()) catch |err| {
                        std.debug.print("{}", .{err});
                    };
                    const third_draw: Draw = parseDraw(gameStrIter.next()) catch |err| {
                        std.debug.print("{}", .{err});
                    };
                    games.append(Game{ .Id = gameId, .first_draw = first_draw, .second_draw = second_draw, .third_draw = third_draw }) catch |err| {
                        std.debug.print("error {}", .{err});
                    };
                }
            } else |err| {
                std.debug.print("failed to parse game id {}", .{err});
            }
        }
    }
    return solution;
}

fn solvePart2(input: []const []const u8) !u32 {
    const total: u32 = 0;
    const allocator = std.heap.page_allocator;
    _ = allocator;
    for (input) |row| {
        _ = row;
    }
    return total;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var lines = try readFile(allocator, "input/input");
    defer lines.deinit();
    std.debug.print("part 1 total: {}\n", .{solvePart1(lines.items)});
    std.debug.print("part 2 total: {}\n", .{solvePart2(lines.items)});
}

test "test part 1" {
    const input =
        \\ Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\ Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\ Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\ Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\ Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    ;
    const allocator = std.heap.page_allocator;
    var fileContents = std.ArrayList(u8).init(allocator);
    try fileContents.appendSlice(input);
    try std.testing.expect(solvePart1(fileContents) == 8);
}
test "test part 2" {
    const input = [_][]const u8{ "two1nine", "eightwothree", "abcone2threexyz", "xtwone3four", "4nineeightseven2", "zoneight234", "7pqrstsixteen" };
    try std.testing.expect(try solvePart2(&input) == 281);
}
