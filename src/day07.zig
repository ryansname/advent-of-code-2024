const std = @import("std");
const mem = std.mem;
const sort = std.sort;

const util = @import("util.zig");

const real_input = @embedFile("input/day07.txt");

pub fn main() !void {
    std.log.info("Part 1: {}", .{try solve(1, real_input)});
    std.log.info("Part 2: {}", .{try solve(2, real_input)});
}

fn solve(part: u2, input: []const u8) !i64 {
    var line_iter = util.iterLines(input);
    var result = @as(i64, 0);
    while (line_iter.next()) |line| {
        var num_strs = util.iterAny(line, " :");
        const target = blk: {
            const num_str = num_strs.next() orelse return error.NoNum;
            break :blk try std.fmt.parseInt(i64, num_str, 10);
        };

        var operands_buf = try std.BoundedArray(i64, 64).init(0);
        while (num_strs.next()) |num_str| {
            const operand = try std.fmt.parseInt(i64, num_str, 10);
            try operands_buf.append(operand);
        }
        const operands = operands_buf.slice();

        const possible = isPossible(part, target, operands[0], operands[1..]);
        if (possible) {
            result += target;
        }
    }
    return result;
}

fn isPossible(part: u2, target: i64, val: i64, operands: []i64) bool {
    if (operands.len == 0) {
        return target == val;
    }
    if (val > target) {
        return false;
    }

    if (isPossible(part, target, val + operands[0], operands[1..])) {
        return true;
    }
    if (isPossible(part, target, val * operands[0], operands[1..])) {
        return true;
    }
    if (part == 2) {
        var next = val;
        var magnitude = operands[0];
        while (magnitude > 0) {
            next *= 10;
            magnitude = @divTrunc(magnitude, 10);
        }
        next += operands[0];

        if (isPossible(part, target, next, operands[1..])) {
            return true;
        }
    }
    return false;
}

const test_input =
    \\190: 10 19
    \\3267: 81 40 27
    \\83: 17 5
    \\156: 15 6
    \\7290: 6 8 6 15
    \\161011: 16 10 13
    \\192: 17 8 14
    \\21037: 9 7 18 13
    \\292: 11 6 16 20
;

test "part 1" {
    try std.testing.expectEqual(3749, solve(1, test_input));
}
test "part 2" {
    try std.testing.expectEqual(11387, solve(2, test_input));
}
