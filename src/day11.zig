const std = @import("std");
const mem = std.mem;
const sort = std.sort;

const util = @import("util.zig");

const real_input = @embedFile("input/day11.txt");

pub fn main() !void {
    std.log.info("Part 1: {}", .{try part1(25, real_input)});
    std.log.info("Part 2: {}", .{try part1(75, real_input)});
}

const Block = struct {
    value: u64,
    count: usize,
    count_b: usize,
};

fn addToBlockValue(value: u64, count: usize, blocks: anytype) !void {
    for (blocks.slice()) |*b| {
        if (b.value == value) {
            b.count_b += count;
            return;
        }
    }
    const new_block = try blocks.addOne();
    new_block.* = .{
        .value = value,
        .count = 0,
        .count_b = count,
    };
}

fn part1(blinks: usize, input: []const u8) !i64 {
    var blocks_buffer = try std.BoundedArray(Block, 10240).init(0);

    var token_iter = util.iterTokens(std.mem.trim(u8, input, "\n "));
    while (token_iter.next()) |token| {
        const value = try std.fmt.parseInt(u64, token, 10);
        try addToBlockValue(value, 1, &blocks_buffer);
    }
    for (blocks_buffer.slice()) |*b| {
        b.count = b.count_b;
        b.count_b = 0;
    }

    for (0..blinks) |_| {
        // defer std.debug.print("\n", .{});
        for (blocks_buffer.slice()) |block| {
            if (block.value == 0) {
                try addToBlockValue(1, block.count, &blocks_buffer);
                continue;
            }

            const number_len = 1 + std.math.log10_int(block.value);
            if (number_len % 2 == 0) {
                // Split block into two. High value goes into a new prev block
                const selector = std.math.powi(u64, 10, number_len / 2) catch |err| std.debug.panic("Bad pow {}", .{err});
                const high = block.value / selector;
                const low = block.value % selector;
                // std.log.err("{} \\ {} -> {} | {}", .{ block.value, selector, high, low });

                try addToBlockValue(high, block.count, &blocks_buffer);
                try addToBlockValue(low, block.count, &blocks_buffer);
                continue;
            }

            try addToBlockValue(block.value * 2024, block.count, &blocks_buffer);
        }

        // Set count = count_b and count_b = 0
        for (blocks_buffer.slice()) |*b| {
            b.count = b.count_b;
            b.count_b = 0;
            // std.log.err("{} = {}", .{ b.value, b.count });
        }
    }

    var blocks: i64 = 0;
    for (blocks_buffer.slice()) |b| blocks += @intCast(b.count);
    return blocks;
}

test "part 1" {
    try std.testing.expectEqual(22, part1(6, "125 17"));
    try std.testing.expectEqual(55312, part1(25, "125 17"));
}
test "part 2" {}
