const std = @import("std");
const mem = std.mem;

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

    var score = @as(i64, 0);
    var score_2 = score;
    z: while (lines.next()) |line| {
        var pages = try std.BoundedArray(i64, 10240).init(0);
        var pages_iter = util.iterCsv(line);
        while (pages_iter.next()) |page_str| {
            const page = try std.fmt.parseInt(i64, page_str, 10);
            try pages.append(page);
        }

        for (0.., pages.slice()) |idx, page| {
            for (instructions.slice()) |i| {
                if (i.before == page) {
                    for (pages.slice()[0..idx]) |p2| {
                        if (i.after == p2) {
                            score_2 += reorder(instructions.slice(), pages.slice());
                            continue :z;
                        }
                    }
                }
            }
        }

        if (pages.len > 0) {
            score += pages.slice()[pages.len / 2];
        }
    }

    if (part == 1) {
        return score;
    } else {
        return score_2;
    }
}

fn reorder(instructions: []Inst, pages: []i64) i64 {
    var dirty = true;
    while (dirty) {
        dirty = false;
        for (0.., pages) |idx, page| {
            for (instructions) |i| {
                if (i.before == page) {
                    for (0.., pages[0..idx]) |idx_2, p2| {
                        if (i.after == p2) {
                            const temp = pages[idx];
                            pages[idx] = pages[idx_2];
                            pages[idx_2] = temp;
                            dirty = true;
                        }
                    }
                }
            }
        }
    }
    if (pages.len > 0) {
        return pages[pages.len / 2];
    }
    return 0;
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
