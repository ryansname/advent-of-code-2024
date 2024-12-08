const std = @import("std");
const mem = std.mem;
const sort = std.sort;

const util = @import("util.zig");

const real_input = @embedFile("input/day08.txt");

pub fn main() !void {
    std.log.info("Part 1: {}", .{try solve(1, real_input)});
    std.log.info("Part 2: {}", .{try solve(2, real_input)});
}

fn Buffer(comptime ty: type) type {
    return std.BoundedArray(ty, 256 * 256);
}

fn solve(part: u2, input: []const u8) !i64 {
    var map_buf = try Buffer(u8).init(0);
    const map, const stride = try util.makeSafeGrid(&map_buf, input, '\n', '.');
    var antinodes = try Buffer(bool).init(0);
    try antinodes.appendNTimes(false, antinodes.capacity());

    inline for ('0'..'9' + 1) |antenna| {
        try processAntenna(part, antinodes.slice(), map, stride, antenna);
    }
    inline for ('a'..'z' + 1) |antenna| {
        try processAntenna(part, antinodes.slice(), map, stride, antenna);
    }
    inline for ('A'..'Z' + 1) |antenna| {
        try processAntenna(part, antinodes.slice(), map, stride, antenna);
    }

    return @intCast(mem.count(bool, antinodes.slice(), &.{true}));
}

fn processAntenna(part: u2, antinodes: []bool, input: []const u8, stride: usize, antenna: u8) !void {
    const dimension = stride - 2;
    var locations_buf = try std.BoundedArray(usize, 1024).init(0);
    for (0.., input) |idx, char| if (char == antenna) try locations_buf.append(idx);
    const locations = locations_buf.slice();
    for (0.., locations) |idx_1, loc_1| {
        const y_1: i64 = @intCast(loc_1 / stride);
        const x_1: i64 = @intCast(loc_1 % stride);

        for (locations[idx_1..]) |loc_2| {
            if (loc_1 == loc_2) continue;
            const y_2: i64 = @intCast(loc_2 / stride);
            const x_2: i64 = @intCast(loc_2 % stride);

            const dx = x_2 - x_1;
            const dy = y_2 - y_1;

            if (part == 1) {
                inline for (.{
                    .{ .x = x_1 - dx, .y = y_1 - dy },
                    .{ .x = x_2 + dx, .y = y_2 + dy },
                }) |antinode| {
                    if (antinode.x > 0 and antinode.y > 0 and
                        antinode.x <= dimension and antinode.y <= dimension)
                    { // Assume square
                        antinodes[@as(usize, @intCast(antinode.x)) + @as(usize, @intCast(antinode.y)) * stride] = true;
                    }
                }
            } else {
                var test_x = x_1;
                var test_y = y_1;

                // Move all the way towards one boundary
                while (test_x > 0 and test_y > 0 and
                    test_x <= dimension and test_y <= dimension)
                {
                    test_x += dx;
                    test_y += dy;
                }

                // Get back in bounds
                test_x -= dx;
                test_y -= dy;

                // Now move all the way to the other boundary, recording all valid positions
                // (There must be at least 2)
                while (test_x > 0 and test_y > 0 and
                    test_x <= dimension and test_y <= dimension)
                {
                    antinodes[@as(usize, @intCast(test_x)) + @as(usize, @intCast(test_y)) * stride] = true;
                    test_x -= dx;
                    test_y -= dy;
                }
            }
        }
    }
}

const basic_input =
    \\..........
    \\...#......
    \\..........
    \\....a.....
    \\..........
    \\.....a....
    \\..........
    \\......#...
    \\..........
    \\..........
;

const test_input =
    \\............
    \\........0...
    \\.....0......
    \\.......0....
    \\....0.......
    \\......A.....
    \\............
    \\............
    \\........A...
    \\.........A..
    \\............
    \\............
;

const perms_input =
    \\............
    \\..v...hh....
    \\..v.........
    \\........g...
    \\.......g....
    \\..l.........
    \\...l........
    \\............
    \\....99......
    \\....zz.a....
    \\....00.a...2
    \\....ZZ....22
;

test "part 1" {
    try std.testing.expectEqual(2, solve(1, basic_input));
    try std.testing.expectEqual(14, solve(1, test_input));
    try std.testing.expectEqual(20, solve(1, perms_input));
}
test "part 2" {
    try std.testing.expectEqual(34, solve(2, test_input));
}
