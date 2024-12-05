const std = @import("std");
const mem = std.mem;
const sort = std.sort;

const util = @import("util.zig");

const real_input = @embedFile("input/day05.txt");

pub fn main() !void {
    std.log.info("Part 1: {}", .{try solve(1, real_input)});
    std.log.info("Part 2: {}", .{try solve(2, real_input)});
}

const Inst = struct {
    before: i64,
    after: i64,
};
fn instLessThan(_: void, lhs: Inst, rhs: Inst) bool {
    var lessThan = lhs.before < rhs.before;
    if (lhs.before == rhs.before) lessThan = lhs.after < rhs.after;

    return lessThan;
}

fn instPageCompare(page: i64, inst: Inst) std.math.Order {
    return std.math.order(page, inst.before);
}

fn pageComesBefore(ctx: []Inst, lhs: i64, rhs: i64) bool {
    const lowerBound = sort.lowerBound(Inst, ctx, lhs, instPageCompare);
    for (ctx[lowerBound..]) |inst| {
        if (inst.before != lhs) break;
        if (inst.after == rhs) return true;
    }
    return false;
}

fn solve(part: u2, input: []const u8) !i64 {
    var lines = mem.splitScalar(u8, input, '\n');

    var instructions = try std.BoundedArray(Inst, 10240).init(0);
    while (lines.next()) |line| {
        const pipe_idx = mem.indexOfScalar(u8, line, '|');

        if (pipe_idx == null) {
            break;
        }

        const before = try std.fmt.parseInt(i64, line[0..pipe_idx.?], 10);
        const after = try std.fmt.parseInt(i64, line[pipe_idx.? + 1 ..], 10);
        try instructions.append(.{ .before = before, .after = after });
    }

    sort.pdq(Inst, instructions.slice(), {}, instLessThan);

    var score = @as(i64, 0);
    var score_2 = score;
    while (lines.next()) |line| {
        var pages = try std.BoundedArray(i64, 10240).init(0);
        var pages_iter = util.iterCsv(line);
        while (pages_iter.next()) |page_str| {
            const page = try std.fmt.parseInt(i64, page_str, 10);
            try pages.append(page);
        }

        if (pages.len > 0) {
            if (sort.isSorted(i64, pages.slice(), instructions.slice(), pageComesBefore)) {
                score += pages.slice()[pages.len / 2];
            } else {
                sort.pdq(i64, pages.slice(), instructions.slice(), pageComesBefore);
                score_2 += pages.slice()[pages.len / 2];
            }
        }
    }

    if (part == 1) {
        return score;
    } else {
        return score_2;
    }
}

const test_input =
    \\47|53
    \\97|13
    \\97|61
    \\97|47
    \\75|29
    \\61|13
    \\75|53
    \\29|13
    \\97|29
    \\53|29
    \\61|53
    \\97|53
    \\61|29
    \\47|13
    \\75|47
    \\97|75
    \\47|61
    \\75|61
    \\47|29
    \\75|13
    \\53|13
    \\
    \\75,47,61,53,29
    \\97,61,53,29,13
    \\75,29,13
    \\75,97,47,61,53
    \\61,13,29
    \\97,13,75,29,47
;

test "part 1" {
    try std.testing.expectEqual(143, solve(1, test_input));
}
test "part 2" {
    try std.testing.expectEqual(123, solve(2, test_input));
}
