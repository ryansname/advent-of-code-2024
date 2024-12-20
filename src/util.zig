const ascii = std.ascii;
const fmt = std.fmt;
const log = std.log;
const math = std.math;
const mem = std.mem;
const std = @import("std");

pub fn iterLines(string: []const u8) mem.TokenIterator(u8, .scalar) {
    return mem.tokenizeScalar(u8, string, '\n');
}

pub fn iterTokens(string: []const u8) mem.TokenIterator(u8, .scalar) {
    return mem.tokenizeScalar(u8, string, ' ');
}

pub fn iterCsv(string: []const u8) mem.TokenIterator(u8, .scalar) {
    return mem.tokenizeScalar(u8, string, ',');
}

pub fn iterAny(string: []const u8, tokens: []const u8) mem.TokenIterator(u8, .any) {
    return mem.tokenizeAny(u8, string, tokens);
}

pub fn parseFn(comptime ty: type) fn ([]const u8) ty {
    const typeInfo = @typeInfo(ty);
    switch (typeInfo) {
        .Float => return struct {
            fn toFloat(input: []const u8) ty {
                return fmt.parseFloat(ty, input) catch |e| {
                    log.err("Failed to parse '{s}' as float: {}", .{ input, e });
                    @panic("Failed to parse int");
                };
            }
        }.toFloat,
        .Int => return struct {
            fn toInt(input: []const u8) ty {
                return std.fmt.parseInt(ty, input, 10) catch |e| {
                    log.err("Failed to parse '{s}' as int: {}", .{ input, e });
                    @panic("Failed to parse int");
                };
            }
        }.toInt,
        else => unreachable,
    }
}

// 2D stuff
pub fn makeSafeGrid(bounded_array: anytype, grid: []const u8, row_delim: u8, sentinel: u8) !struct { []u8, usize } {
    const stride = 2 + (mem.indexOfScalar(u8, grid, row_delim) orelse return error.NoNewline);

    try bounded_array.appendNTimes(sentinel, stride);
    var lines = iterLines(grid);
    while (lines.next()) |line| {
        try bounded_array.append(sentinel);
        try bounded_array.appendSlice(line);
        try bounded_array.append(sentinel);
    }
    try bounded_array.appendNTimes(sentinel, stride);
    return .{ bounded_array.slice(), stride };
}

pub fn Dir(comptime dirs: u8) type {
    return switch (dirs) {
        4 => enum {
            N,
            S,
            E,
            W,

            pub fn inverse(self: Dir(4)) Dir(4) {
                return switch (self) {
                    .N => .S,
                    .S => .N,
                    .E => .W,
                    .W => .E,
                };
            }
        },
        8 => enum { N, S, E, W, NE, SE, NW, SW },
        else => @compileError("Unsupported number of dirs " ++ dirs),
    };
}

pub fn indexForDir(dir: anytype, idx: usize, stride: usize) usize {
    if (@TypeOf(dir) == Dir(4)) {
        return switch (dir) {
            .N => idx - stride,
            .S => idx + stride,
            .W => idx - 1,
            .E => idx + 1,
        };
    }
    if (@TypeOf(dir) == Dir(8)) {
        return switch (dir) {
            .N => idx - stride,
            .S => idx + stride,
            .W => idx - 1,
            .E => idx + 1,
            .NW => idx - stride - 1,
            .NE => idx - stride + 1,
            .SW => idx + stride - 1,
            .SE => idx + stride + 1,
        };
    }
    @compileError("Unsupported type " ++ @typeName(@TypeOf(dir)));
}

pub fn rotateRight(dir: anytype) @TypeOf(dir) {
    return switch (@TypeOf(dir)) {
        Dir(4) => switch (dir) {
            .N => .E,
            .E => .S,
            .S => .W,
            .W => .N,
        },
        Dir(8) => switch (dir) {
            .N => .NE,
            .NE => .E,
            .E => .SE,
            .SE => .S,
            .S => .SW,
            .SW => .W,
            .W => .NW,
        },
        else => @compileError("Unsupported type" ++ @typeName(@TypeOf(dir))),
    };
}

pub fn NeighboursReturn(comptime dirs: u8, comptime BufferType: type) type {
    return [dirs]struct { char: @typeInfo(BufferType).pointer.child, idx: usize, dir: Dir(dirs) };
}

pub fn getNeighbours(comptime dirs: u8, buffer: anytype, i: usize, stride: usize) NeighboursReturn(dirs, @TypeOf(buffer)) {
    const offsets = switch (dirs) {
        4 => .{
            .{ i - stride, .N },
            .{ i + stride, .S },
            .{ i - 1, .W },
            .{ i + 1, .E },
        },
        8 => .{
            .{ i - stride, .N },
            .{ i - stride - 1, .NW },
            .{ i - stride + 1, .NE },
            .{ i + stride, .S },
            .{ i + stride - 1, .SW },
            .{ i + stride + 1, .SE },
            .{ i - 1, .W },
            .{ i + 1, .E },
        },
        else => @compileError("Unsupported number of dirs " ++ dirs),
    };

    var result: NeighboursReturn(dirs, @TypeOf(buffer)) = undefined;

    inline for (offsets, &result) |d, *r| {
        r.* = .{
            .char = buffer[d.@"0"],
            .idx = d.@"0",
            .dir = d.@"1",
        };
    }
    return result;
}
