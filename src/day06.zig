const std = @import("std");
const mem = std.mem;
const sort = std.sort;

const util = @import("util.zig");

const real_input = @embedFile("input/day06.txt");

pub fn main() !void {
    std.log.info("Part 1: {}", .{try solve(1, real_input)});
    std.log.info("Part 2: {}", .{try solve(2, real_input)});
}

const Dir = util.Dir(4);

fn isLoopin(grid: []const u8, stride: usize) bool {
    var dude_idx = std.mem.indexOfScalar(u8, grid, '^') orelse return false;
    var dude_dir = Dir.N;

    const step_limit = grid.len / 2;
    var steps = @as(i64, 0);
    while (grid[dude_idx] != 'E') {
        const idx = util.indexForDir(dude_dir, dude_idx, stride);
        if (grid[idx] == '#' or grid[idx] == 'O') {
            dude_dir = util.rotateRight(dude_dir);
            continue;
        }
        dude_idx = idx;
        steps += 1;
        if (steps > step_limit) {
            return true;
        }
    }
    return false;
}

fn solve(part: u2, input: []const u8) !i64 {
    var grid_buf = try std.BoundedArray(u8, 1024 * 1024).init(0);
    var visit_buf = try std.BoundedArray(bool, 1024 * 1024).init(0);
    const grid, const stride = try util.makeSafeGrid(&grid_buf, input, '\n', 'E');
    try visit_buf.appendNTimes(false, grid.len);
    var visit = visit_buf.slice();

    var dude_idx = std.mem.indexOfScalar(u8, grid, '^') orelse return 0;
    var dude_dir = Dir.N;

    if (part == 1) {
        visit[dude_idx] = true;
        while (grid[dude_idx] != 'E') {
            visit[dude_idx] = true;

            const idx = util.indexForDir(dude_dir, dude_idx, stride);
            if (grid[idx] == '#') {
                dude_dir = util.rotateRight(dude_dir);
                continue;
            }
            dude_idx = idx;
        }
        return @intCast(mem.count(bool, visit, &[_]bool{true}));
    } else {
        var count = @as(i64, 0);
        for (0..grid.len) |idx| {
            if (grid[idx] != '.') continue;
            grid[idx] = 'O';
            defer grid[idx] = '.';
            if (isLoopin(grid, stride)) {
                count += 1;
            }
        }
        return count;
    }
}

const test_input =
    \\....#.....
    \\.........#
    \\..........
    \\..#.......
    \\.......#..
    \\..........
    \\.#..^.....
    \\........#.
    \\#.........
    \\......#...
;

test "part 1" {
    try std.testing.expectEqual(41, solve(1, test_input));
}
test "part 2" {
    try std.testing.expectEqual(6, solve(2, test_input));
}
