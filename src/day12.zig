const std = @import("std");
const mem = std.mem;
const sort = std.sort;

const util = @import("util.zig");

const real_input = @embedFile("input/day12.txt");

pub fn main() !void {
    std.log.info("Part 1: {}", .{try solve(1, real_input)});
    std.log.info("Part 2: {}", .{try solve(2, real_input)});
}

fn printMap(reachable_count: []i64, stride: usize) void {
    std.debug.print("\n", .{});
    defer std.debug.print("\n", .{});

    var idx: usize = 0;
    while (idx < reachable_count.len) : (idx += 1) {
        std.debug.print("{d} ", .{reachable_count[idx]});
        if (idx % stride == stride - 1) std.debug.print("\n", .{});
    }
}

fn solve(comptime part: comptime_int, input: []const u8) !i64 {
    const CAP = 102400;
    var buf = try std.BoundedArray(u8, CAP).init(0);
    const map, const stride = try util.makeSafeGrid(&buf, input, '\n', '+');
    var regions = [_]i64{0} ** CAP;
    var next_region: i64 = 1;

    for (0.., map) |idx, val| {
        if (regions[idx] != 0) continue;
        if (map[idx] == '+') continue;

        //     std.debug.print("Considering region at index [{}] = {c}\n", .{ idx, val });

        const this_region = next_region;
        next_region += 1;
        regions[idx] = this_region;

        var wavefront = try std.BoundedArray(usize, 1024).init(0);
        wavefront.appendAssumeCapacity(idx);

        while (wavefront.len != 0) {
            // printMap(regions[0..map.len], stride);
            // var b = [1]u8{0};
            // _ = try std.io.getStdIn().read(&b);
            const test_idx = wavefront.swapRemove(0);

            for (util.getNeighbours(4, map, test_idx, stride)) |n| {
                //             std.debug.print("Considering neighbour at index [{}] = {c}:", .{ n.idx, val });
                //             defer std.debug.print(" bad\n", .{});
                if (map[n.idx] != val) continue;
                if (map[n.idx] == '+') continue;
                if (regions[n.idx] != 0) continue;
                //             defer std.debug.print(" not", .{});

                regions[n.idx] = this_region;

                try wavefront.append(n.idx);
            }
        }
    }

    var score: i64 = 0;
    if (part == 1) {
        for (1..@intCast(next_region)) |r_id| {
            var perimiter: i64 = 0;
            var area: i64 = 0;

            for (0.., regions) |idx, r| {
                if (r != r_id) continue;
                area += 1;

                for (util.getNeighbours(4, regions[0..map.len], idx, stride)) |n| {
                    if (regions[n.idx] != r) perimiter += 1;
                }
            }

            score += perimiter * area;
        }
    } else {
        for (1..@intCast(next_region)) |r_id| {
            var sides: i64 = 0;
            var area: i64 = 0;

            for (0.., regions) |idx, r| {
                if (r != r_id) continue;
                area += 1;

                var r_n: bool = undefined;
                var r_e: bool = undefined;
                var r_s: bool = undefined;
                var r_w: bool = undefined;
                var r_ne: bool = undefined;
                var r_nw: bool = undefined;
                var r_se: bool = undefined;
                var r_sw: bool = undefined;
                for (util.getNeighbours(8, regions[0..map.len], idx, stride)) |n| {
                    switch (n.dir) {
                        .N => r_n = n.char == r,
                        .E => r_e = n.char == r,
                        .S => r_s = n.char == r,
                        .W => r_w = n.char == r,
                        .NE => r_ne = n.char == r,
                        .NW => r_nw = n.char == r,
                        .SE => r_se = n.char == r,
                        .SW => r_sw = n.char == r,
                    }
                }
                var matching_edges: i64 = 0;
                if (r_n) matching_edges += 1;
                if (r_e) matching_edges += 1;
                if (r_s) matching_edges += 1;
                if (r_w) matching_edges += 1;

                sides += switch (matching_edges) {
                    0 => 4,
                    1 => 2,
                    2 => if (r_n and r_s or r_e and r_w) 0 else 1,
                    3 => 0,
                    4 => 0,
                    else => unreachable,
                };

                if (r_n and r_e and !r_ne) sides += 1;
                if (r_e and r_s and !r_se) sides += 1;
                if (r_s and r_w and !r_sw) sides += 1;
                if (r_w and r_n and !r_nw) sides += 1;
            }
            // std.debug.print("Region {} has {} sides\n", .{ r_id, sides });

            score += sides * area;
        }
    }

    return score;
}

const test_input_1 =
    \\OOOOO
    \\OXOXO
    \\OOOOO
    \\OXOXO
    \\OOOOO
;

const test_input_2 =
    \\AAAAAA
    \\AAABBA
    \\AAABBA
    \\ABBAAA
    \\ABBAAA
    \\AAAAAA
;

test "part 1" {
    try std.testing.expectEqual(772, solve(1, test_input_1));
}
test "part 2" {
    try std.testing.expectEqual(368, solve(2, test_input_2));
}
