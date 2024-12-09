const std = @import("std");
const mem = std.mem;
const sort = std.sort;

const util = @import("util.zig");

const real_input = @embedFile("input/day09.txt");

pub fn main() !void {
    std.log.info("Part 1: {}", .{try part1(real_input)});
    std.log.info("Part 2: {}", .{try part2(real_input)});
}

const blank = std.math.maxInt(i64);

const Block = struct {
    id: usize,
    size: usize,
    file: bool,

    prev: ?*Block,
    next: ?*Block,
};

fn part2(input: []const u8) !i64 {
    var blocks_buffer = try std.BoundedArray(Block, 102400).init(0);

    var next_id = @as(usize, 0);
    var file = true;
    var prev: ?*Block = null;
    for (input) |char| {
        if (char == '\n') break;
        var block = try blocks_buffer.addOne();

        block.file = file;
        defer file = !file;
        if (file) {
            block.id = next_id;
            next_id += 1;
        }

        block.size = char - '0';

        block.prev = prev;
        if (prev) |p| p.next = block;
        defer prev = block;
    }
    const blocks = blocks_buffer.slice();

    var next = prev;
    block: while (next) |high_block| {
        next = high_block.prev;

        if (!high_block.file) continue;

        // Find a suitable gap, or not
        var search: ?*Block = &blocks[0];
        const block_with_space = search: while (search) |block| : (search = block.next) {
            if (block == high_block) continue :block;
            if (block.file) continue;
            if (block.size < high_block.size) continue;
            break :search block;
        } else continue;

        // Remove the now used size, 0 size gaps can stay for laziness
        block_with_space.size -= high_block.size;

        // Create a new block
        const block = try blocks_buffer.addOne();
        block.* = .{
            .id = high_block.id,
            .size = high_block.size,
            .file = true,
            .prev = block_with_space.prev,
            .next = block_with_space,
        };

        // Insert it into place
        if (block_with_space.prev) |p| p.next = block;
        block_with_space.prev = block;

        // Zero and blank out the old high_block
        high_block.id = 0;
        high_block.file = false;
    }

    var score = @as(usize, 0);
    var idx = @as(usize, 0);
    var iter: ?*Block = &blocks[0];
    while (iter) |block| : (iter = block.next) {
        defer idx += block.size;
        if (!block.file) continue;

        for (idx..idx + block.size) |i| {
            score += i * block.id;
        }
    }

    return @intCast(score);
}

fn printList(start: *const Block) void {
    var iter: ?*const Block = start;
    while (iter) |b| : (iter = b.next) {
        const char: u8 = if (!b.file) '.' else @as(u8, @intCast(b.id)) + '0';
        for (0..b.size) |_| {
            std.io.getStdOut().writeAll(&[_]u8{char}) catch unreachable;
        }
    }
    std.io.getStdOut().writeAll("\n") catch unreachable;
}

fn part1(input: []const u8) !i64 {
    var block_id_buffer = try std.BoundedArray(i64, 102400).init(0);
    var next_id = @as(i64, 0);
    var file = true;
    for (input) |char| {
        if (char == '\n') break;
        const len = char - '0';
        if (file) {
            try block_id_buffer.appendNTimes(next_id, len);
            next_id += 1;
        } else {
            try block_id_buffer.appendNTimes(blank, len);
        }
        file = !file;
    }
    const block_ids = block_id_buffer.slice();

    var low_idx = @as(usize, 0);
    var high_idx = block_ids.len - 1;
    while (low_idx < high_idx) {
        if (block_ids[low_idx] != blank) {
            low_idx += 1;
            continue;
        }
        if (block_ids[high_idx] == blank) {
            high_idx -= 1;
            continue;
        }
        block_ids[low_idx] = block_ids[high_idx];
        block_ids[high_idx] = blank;
    }

    var score = @as(i64, 0);
    for (0.., block_ids[0..low_idx]) |idx, id| {
        score += @as(i64, @intCast(idx)) * id;
    }

    return score;
}

test "part 1" {
    try std.testing.expectEqual(1928, part1("2333133121414131402"));
    try std.testing.expectEqual(60, part1("12345"));
}
test "part 2" {
    try std.testing.expectEqual(2858, part2("2333133121414131402"));
}
