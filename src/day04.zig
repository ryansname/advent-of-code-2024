const std = @import("std");
const mem = std.mem;

const util = @import("util.zig");

const real_input = @embedFile("input/day04.txt");

const Dir = util.Dir(8);

pub fn main() !void {
    std.log.info("Part 1: {}", .{try solve(1, real_input)});
    std.log.info("Part 2: {}", .{try solve(2, real_input)});
}
fn solve(comptime part: u2, raw_input: []const u8) !i64 {
    var input_builder = try std.BoundedArray(u8, 1024 * 1024).init(0);
    const stride = 2 + (mem.indexOfScalar(u8, raw_input, '\n') orelse return error.NoNewline);

    try input_builder.appendNTimes('.', stride);
    var lines = util.iterLines(raw_input);
    while (lines.next()) |line| {
        try input_builder.append('.');
        try input_builder.appendSlice(line);
        try input_builder.append('.');
    }
    try input_builder.appendNTimes('.', stride);
    const input = input_builder.slice();

    var count: i64 = 0;
    if (part == 1) {
        for (0.., input) |i, c| {
            switch (c) {
                'X' => {
                    for (std.enums.values(Dir)) |dir| {
                        const m_idx = util.indexForDir(dir, i, stride);
                        if (input[m_idx] != 'M') continue;
                        const a_idx = util.indexForDir(dir, m_idx, stride);
                        if (input[a_idx] != 'A') continue;
                        const s_idx = util.indexForDir(dir, a_idx, stride);
                        if (input[s_idx] != 'S') continue;
                        count += 1;
                    }
                },
                else => {},
            }
        }
    } else {
        for (0.., input) |i, c| {
            switch (c) {
                'A' => {
                    const ne = input[util.indexForDir(Dir.NE, i, stride)];
                    const nw = input[util.indexForDir(Dir.NW, i, stride)];
                    const se = input[util.indexForDir(Dir.SE, i, stride)];
                    const sw = input[util.indexForDir(Dir.SW, i, stride)];

                    const mas_1 = nw == 'M' and se == 'S' or nw == 'S' and se == 'M';
                    const mas_2 = ne == 'M' and sw == 'S' or ne == 'S' and sw == 'M';
                    if (mas_1 and mas_2) count += 1;
                },
                else => {},
            }
        }
    }

    return count;
}

const test_input_1 =
    \\..X...
    \\.SAMX.
    \\.A..A.
    \\XMAS.S
    \\.X....
;

const test_input_2 =
    \\MMMSXXMASM
    \\MSAMXMSMSA
    \\AMXSXMAAMM
    \\MSAMASMSMX
    \\XMASAMXAMM
    \\XXAMMXXAMA
    \\SMSMSASXSS
    \\SAXAMASAAA
    \\MAMMMXMMMM
    \\MXMXAXMASX
;

const test_input_3 =
    \\.M.S......
    \\..A..MSMS.
    \\.M.S.MAA..
    \\..A.ASMSM.
    \\.M.S.M....
    \\..........
    \\S.S.S.S.S.
    \\.A.A.A.A..
    \\M.M.M.M.M.
    \\..........
;

test "part 1" {
    try std.testing.expectEqual(4, solve(1, test_input_1));
    try std.testing.expectEqual(18, solve(1, test_input_2));
}

test "part 2" {
    try std.testing.expectEqual(9, solve(2, test_input_3));
}
