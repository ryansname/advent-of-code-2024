const std = @import("std");
const mem = std.mem;

const real_input = @embedFile("input/day03.txt");

pub fn main() void {
    std.log.info("Part 1: {}", .{solve(false, real_input)});
    // 97767434 Low
    // 99259801 Low
    std.log.info("Part 2: {}", .{solve(true, real_input)});
}

const state = enum { none, lval, rval, done };

fn test_print(label: []const u8, input: []const u8, idx: usize) void {
    _ = idx;
    _ = input;
    _ = label;
    // std.log.info("{s} {s}", .{ label, input[idx..@min(input.len, idx + 10)] });
}

fn solve(part_2: bool, input: []const u8) i64 {
    var idx: usize = 0;

    var enable = true;

    var lval: i64 = 0;
    var rval: i64 = 0;
    var score: i64 = 0;

    while (idx < input.len - 3) {
        p: switch (@as(state, .none)) {
            .none => {
                test_print("none", input, idx);
                if (enable and mem.startsWith(u8, input[idx..], "mul(")) {
                    idx += "mul(".len;
                    continue :p .lval;
                }
                if (part_2) {
                    // std.log.err("{s}", .{input[idx..]});
                    if (mem.startsWith(u8, input[idx..], "do()")) {
                        enable = true;
                        idx += "do()".len;
                        continue;
                    }
                    if (mem.startsWith(u8, input[idx..], "don't()")) {
                        enable = false;
                        idx += "don't()".len;
                        continue;
                    }
                }

                idx += 1;
            },
            .lval => {
                test_print("lval", input, idx);
                const num_str = std.mem.sliceTo(input[idx..], ',');
                lval = std.fmt.parseInt(i64, num_str, 10) catch continue;
                idx += num_str.len;
                if (idx >= input.len or input[idx] != ',') continue;
                idx += 1;
                continue :p .rval;
            },
            .rval => {
                test_print("rval", input, idx);
                const num_str = std.mem.sliceTo(input[idx..], ')');
                rval = std.fmt.parseInt(i64, num_str, 10) catch continue;
                idx += num_str.len;
                if (idx >= input.len or input[idx] != ')') continue;
                idx += 1;
                continue :p .done;
            },
            .done => {
                test_print("done", input, idx);
                score += lval * rval;
                continue;
            },
        }
    }

    return score;
}

test "part 1" {
    try std.testing.expectEqual(161, solve(false, "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"));
}
test "part 2" {
    try std.testing.expectEqual(48, solve(true, "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"));
}
