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

const Draw = struct {
    red: ?u16,
    green: ?u16,
    blue: ?u16,
};

fn parseDraw(drawStr: []const u8) Draw {
    var drawStrIter = std.mem.splitSequence(u8, drawStr, ", ");
    var draw = Draw{ .red = null, .green = null, .blue = null };
    while (drawStrIter.next()) |dice| {
        var diceIter = std.mem.splitSequence(u8, dice, " ");
        const value = if (diceIter.next()) |val| val else "0";
        if (std.fmt.parseInt(u16, value, 10)) |val| {
            if (diceIter.next()) |color| {
                if (std.mem.eql(u8, color, "red")) {
                    draw.red = val;
                } else if (std.mem.eql(u8, color, "green")) {
                    draw.green = val;
                } else if (std.mem.eql(u8, color, "blue")) {
                    draw.blue = val;
                }
            }
        } else |err| {
            std.debug.print("{}", .{err});
        }
    }
    return draw;
}

pub fn isDrawIllegal(self: Draw, redLimit: u16, greenLimit: u16, blueLimit: u16) bool {
    var illegal = false;
    if (self.red) |red| {
        illegal = illegal or red > redLimit;
    }
    if (self.green) |green| {
        illegal = illegal or green > greenLimit;
    }
    if (self.blue) |blue| {
        illegal = illegal or blue > blueLimit;
    }
    return illegal;
}

const Game = struct {
    Id: u32,
    draws: std.ArrayList(Draw),
};

fn isGameImpossible(self: Game, redLimit: u16, greenLimit: u16, blueLimit: u16) bool {
    var impossible = false;
    for (self.draws.items) |draw| {
        std.debug.print("id: {} => r{?} g{?} b{?}", .{ self.Id, draw.red, draw.green, draw.blue });
        impossible = impossible or isDrawIllegal(draw, redLimit, greenLimit, blueLimit);
    }
    if (impossible) {
        std.debug.print("{} is impossible\n\n", .{self.Id});
    }
    return impossible;
}

fn calculateGamePower(self: Game) u32 {
    var gamePower: u16 = 0;
    var fewestRed: u16 = 0;
    var fewestGreen: u16 = 0;
    var fewestBlue: u16 = 0;
    for (self.draws.items) |draw| {
        if (draw.red) |red| {
            if (red > fewestRed) {
                fewestRed = red;
            }
        }
        if (draw.green) |green| {
            if (green > fewestGreen) {
                fewestGreen = green;
            }
        }
        if (draw.blue) |blue| {
            if (blue > fewestBlue) {
                fewestBlue = blue;
            }
        }
    }
    gamePower = fewestRed * fewestGreen * fewestBlue;
    return gamePower;
}

fn solvePart1(input: std.ArrayList(u8)) u32 {
    var solution: u32 = 0;

    var linesIter = std.mem.splitScalar(u8, input.items, '\n');
    var games = std.ArrayList(Game).init(std.heap.page_allocator);
    while (linesIter.next()) |row| {
        //std.debug.print("\n{s}", .{row});
        var lineIter = std.mem.splitSequence(u8, row, ": ");
        const gameStr = lineIter.first();
        if (std.mem.indexOf(u8, gameStr, " ")) |spacePos| {
            const gameIdStr = gameStr[spacePos + 1 ..];
            const trimmedNumberPart = std.mem.trim(u8, gameIdStr, " \n\r\t");
            if (std.fmt.parseInt(u32, trimmedNumberPart, 10)) |gameId| {
                var game = Game{ .Id = gameId, .draws = std.ArrayList(Draw).init(std.heap.page_allocator) };
                if (lineIter.peek()) |cubeDraws| {
                    var cubeDrawIterator = std.mem.splitSequence(u8, cubeDraws, "; ");
                    while (cubeDrawIterator.next()) |drawStr| {
                        std.debug.print("game {} drawStr {s}\n", .{ gameId, drawStr });
                        const draw: Draw = parseDraw(drawStr);
                        game.draws.append(draw) catch |err| {
                            std.debug.print("error {}", .{err});
                        };
                    }
                }
                games.append(game) catch |err| {
                    std.debug.print("{}", .{err});
                };
            } else |err| {
                std.debug.print("failed to parse game id {}, idStr {s}\n", .{ err, gameIdStr });
            }
        }
    }
    const redCubeLimit: u16 = 12;
    const greenCubeLimit: u16 = 13;
    const blueCubeLimit: u16 = 14;
    for (games.items) |game| {
        if (isGameImpossible(game, redCubeLimit, greenCubeLimit, blueCubeLimit)) {
            std.debug.print("{} is impossible\n", .{game.Id});
        } else {
            std.debug.print("{} is possible\n", .{game.Id});
            solution = solution + game.Id;
        }
    }
    return solution;
}

fn solvePart2(input: std.ArrayList(u8)) u32 {
    var solution: u32 = 0;

    var linesIter = std.mem.splitScalar(u8, input.items, '\n');
    var games = std.ArrayList(Game).init(std.heap.page_allocator);
    while (linesIter.next()) |row| {
        //std.debug.print("\n{s}", .{row});
        var lineIter = std.mem.splitSequence(u8, row, ": ");
        const gameStr = lineIter.first();
        if (std.mem.indexOf(u8, gameStr, " ")) |spacePos| {
            const gameIdStr = gameStr[spacePos + 1 ..];
            const trimmedNumberPart = std.mem.trim(u8, gameIdStr, " \n\r\t");
            if (std.fmt.parseInt(u32, trimmedNumberPart, 10)) |gameId| {
                var game = Game{ .Id = gameId, .draws = std.ArrayList(Draw).init(std.heap.page_allocator) };
                if (lineIter.peek()) |cubeDraws| {
                    var cubeDrawIterator = std.mem.splitSequence(u8, cubeDraws, "; ");
                    while (cubeDrawIterator.next()) |drawStr| {
                        std.debug.print("game {} drawStr {s}\n", .{ gameId, drawStr });
                        const draw: Draw = parseDraw(drawStr);
                        game.draws.append(draw) catch |err| {
                            std.debug.print("error {}", .{err});
                        };
                    }
                }
                games.append(game) catch |err| {
                    std.debug.print("{}", .{err});
                };
            } else |err| {
                std.debug.print("failed to parse game id {}, idStr {s}\n", .{ err, gameIdStr });
            }
        }
    }
    for (games.items) |game| {
        const gamePower: u32 = calculateGamePower(game);
        solution = solution + gamePower;
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
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    ;
    const allocator = std.heap.page_allocator;
    var fileContents = std.ArrayList(u8).init(allocator);
    try fileContents.appendSlice(input);
    try std.testing.expect(solvePart1(fileContents) == 8);
}
test "test part 2" {
    const input =
        \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    ;
    const allocator = std.heap.page_allocator;
    var fileContents = std.ArrayList(u8).init(allocator);
    try fileContents.appendSlice(input);
    try std.testing.expect(solvePart2(fileContents) == 2286);
}
