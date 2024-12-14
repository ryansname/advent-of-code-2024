const std = @import("std");
const mem = std.mem;
const sort = std.sort;

const util = @import("util.zig");

const real_input = @embedFile("input/day14.txt");

pub fn main() !void {
    std.log.info("Part 1: {}", .{try part1(real_input, 100, .{ .x = 101, .y = 103 })});
    std.log.info("Part 2: {}", .{try part2(real_input, .{ .x = 101, .y = 103 })});
}

const V2 = struct {
    x: i64,
    y: i64,
};

const Bot = struct {
    pos: V2,
    vel: V2,
};

fn print(bots: []Bot, comptime size: V2) !void {
    var counts = [_]usize{0} ** size.x ** size.y;
    for (bots) |bot| {
        counts[@intCast(bot.pos.x + bot.pos.y * size.x)] += 1;
    }

    std.debug.print("\n", .{});
    for (0.., counts) |idx, c| {
        if (idx % size.x == 0) {
            std.debug.print("\n", .{});
        }
        if (c == 0) {
            std.debug.print(" ", .{});
        } else {
            std.debug.print("{}", .{c});
        }
    }
    std.debug.print("\n", .{});
}

fn part1(input: []const u8, sim_seconds: u32, comptime size: V2) !i64 {
    const bots = (blk: {
        var buf = try std.BoundedArray(Bot, 1024).init(0);

        var tokens = std.mem.tokenizeAny(u8, input, "\n=, ");
        // consume p
        while (tokens.next()) |_| {
            var bot = try buf.addOne();

            bot.pos.x = try std.fmt.parseInt(i64, tokens.next().?, 10);
            bot.pos.y = try std.fmt.parseInt(i64, tokens.next().?, 10);

            // consume v
            _ = tokens.next().?;

            bot.vel.x = try std.fmt.parseInt(i64, tokens.next().?, 10);
            bot.vel.y = try std.fmt.parseInt(i64, tokens.next().?, 10);
        }

        break :blk buf;
    }).slice();

    for (bots) |*bot| {
        bot.pos.x += bot.vel.x * sim_seconds;
        bot.pos.x = @mod(bot.pos.x, size.x);
        bot.pos.y += bot.vel.y * sim_seconds;
        bot.pos.y = @mod(bot.pos.y, size.y);
    }

    var score: i64 = 1;
    const half_x = @divTrunc(size.x, 2);
    const half_y = @divTrunc(size.y, 2);
    inline for (.{ .{ 0, half_x }, .{ 1 + half_x, size.x } }) |x_range| {
        const min_x, const max_x = x_range;
        inline for (.{ .{ 0, half_y }, .{ 1 + half_y, size.y } }) |y_range| {
            const min_y, const max_y = y_range;

            // std.debug.print("\n\nChecking area ({}, {}) to ({}, {})\n", .{ min_x, min_y, max_x, max_y });

            var area_score: i64 = 0;
            for (bots) |bot| {
                //     std.debug.print("\tBot: ({}, {}): ", bot.pos);
                if (min_x <= bot.pos.x and bot.pos.x < max_x and min_y <= bot.pos.y and bot.pos.y < max_y) {
                    area_score += 1;
                    //         std.debug.print("in", .{});
                } else {
                    //         std.debug.print("out", .{});
                }
                //     std.debug.print("\n", .{});
            }

            score *= area_score;
        }
    }

    return score;
}

fn part2(input: []const u8, comptime size: V2) !i64 {
    const bots = (blk: {
        var buf = try std.BoundedArray(Bot, 1024).init(0);

        var tokens = std.mem.tokenizeAny(u8, input, "\n=, ");
        // consume p
        while (tokens.next()) |_| {
            var bot = try buf.addOne();

            bot.pos.x = try std.fmt.parseInt(i64, tokens.next().?, 10);
            bot.pos.y = try std.fmt.parseInt(i64, tokens.next().?, 10);

            // consume v
            _ = tokens.next().?;

            bot.vel.x = try std.fmt.parseInt(i64, tokens.next().?, 10);
            bot.vel.y = try std.fmt.parseInt(i64, tokens.next().?, 10);
        }

        break :blk buf;
    }).slice();

    const redacted_solution = 0;
    const time: i64 = redacted_solution;
    for (bots) |*bot| {
        bot.pos.x += bot.vel.x * time;
        bot.pos.x = @mod(bot.pos.x, size.x);
        bot.pos.y += bot.vel.y * time;
        bot.pos.y = @mod(bot.pos.y, size.y);
    }
    try print(bots, size);

    // A pile of stuff I used to solve the problem

    // const sim_seconds = size.x * size.y;
    // const sim_seconds = 163 - 60;
    // var time: i64 = 60 + sim_seconds * 50;
    // for (bots) |*bot| {
    //     bot.pos.x += bot.vel.x * time;
    //     bot.pos.x = @mod(bot.pos.x, size.x);
    //     bot.pos.y += bot.vel.y * time;
    //     bot.pos.y = @mod(bot.pos.y, size.y);
    // }
    // for (@intCast(time)..9999999999999999999) |_| {
    //     // if (time > 7270) {
    //     // break;
    //     // }

    //     std.debug.print("\x1bc", .{});
    //     std.debug.print("step: {}\n", .{time});
    //     try print(bots, size);

    //     for (bots) |*bot| {
    //         bot.pos.x += bot.vel.x * sim_seconds;
    //         bot.pos.x = @mod(bot.pos.x, size.x);
    //         bot.pos.y += bot.vel.y * sim_seconds;
    //         bot.pos.y = @mod(bot.pos.y, size.y);
    //     }
    //     time += sim_seconds;
    //     std.time.sleep(@divTrunc(1_000_000_000, 101));
    // }

    return 0;
}

const test_input =
    \\p=0,4 v=3,-3
    \\p=6,3 v=-1,-3
    \\p=10,3 v=-1,2
    \\p=2,0 v=2,-1
    \\p=0,0 v=1,3
    \\p=3,0 v=-2,-2
    \\p=7,6 v=-1,-3
    \\p=3,0 v=-1,-2
    \\p=9,3 v=2,3
    \\p=7,3 v=-1,2
    \\p=2,4 v=2,-3
    \\p=9,5 v=-3,-3
;

test "part 1" {
    try std.testing.expectEqual(12, part1(test_input, 100, .{ .x = 11, .y = 7 }));
}
test "part 2" {}
