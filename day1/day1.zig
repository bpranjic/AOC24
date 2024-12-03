const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    const allocator = std.heap.page_allocator;
    var left_numbers = std.ArrayList(u32).init(allocator);
    defer left_numbers.deinit();
    var right_numbers = std.ArrayList(u32).init(allocator);
    defer right_numbers.deinit();
    var right_hashmap = std.AutoHashMap(u32, u32).init(allocator);
    defer right_hashmap.deinit();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const values = try split_values(line);
        try left_numbers.append(values.left);
        try right_numbers.append(values.right);
        const v = try right_hashmap.getOrPut(values.right);
        if (!v.found_existing) {
            v.value_ptr.* = 1;
        } else {
            v.value_ptr.* += 1;
        }
    }
    std.mem.sort(u32, left_numbers.items, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, right_numbers.items, {}, comptime std.sort.asc(u32));
    const res1: u32 = part1(left_numbers, right_numbers);
    const res2: u32 = part2(left_numbers, right_hashmap);
    std.debug.print("Part 1: {d}\n", .{res1});
    std.debug.print("Part 2: {d}\n", .{res2});
}

pub fn part1(left_numbers: std.ArrayList(u32), right_numbers: std.ArrayList(u32)) u32 {
    var sum: u32 = 0;
    for (left_numbers.items, right_numbers.items) |l, r| {
        // Safely compare difference between numbers without panic overflow
        sum += if (l > r) l - r else if (r > l) r - l else 0;
    }
    return sum;
}

pub fn part2(left_numbers: std.ArrayList(u32), right_hashmap: std.AutoHashMap(u32, u32)) u32 {
    var sum: u32 = 0;
    for (left_numbers.items) |num| {
        const value = right_hashmap.get(num);
        if (value) |v| {
            sum += num * v;
        } else {
            continue;
        }
    }
    return sum;
}

pub fn split_values(line: []u8) !struct { left: u32, right: u32 } {
    var it = std.mem.splitAny(u8, line, " ");
    const left_str = it.first();
    var right_str: []const u8 = "";
    while (it.next()) |s| {
        right_str = s;
    }
    const left_num = try std.fmt.parseUnsigned(u32, left_str, 10);
    const right_num = try std.fmt.parseUnsigned(u32, right_str, 10);
    return .{ .left = left_num, .right = right_num };
}
