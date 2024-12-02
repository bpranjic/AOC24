const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    const allocator = std.heap.page_allocator;
    var buf: [100000]u8 = undefined;

    var res1: u32 = 0;
    var res2: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var numbers = std.ArrayList(u32).init(allocator);
        var it = std.mem.splitAny(u8, line, " ");
        while (it.next()) |val| {
            const num = try std.fmt.parseUnsigned(u32, val, 10);
            try numbers.append(num);
        }
        if (try is_safe(numbers)) res1 += 1;
        for (0..numbers.items.len) |i| {
            var tmp = try numbers.clone();
            _ = tmp.orderedRemove(i);
            if (try is_safe(tmp)) {
                res2 += 1;
                break;
            }
        }
    }
    std.debug.print("Part 1: {d}\n", .{res1});
    std.debug.print("Part 2: {d}\n", .{res2});
}

pub fn is_safe(numbers: std.ArrayList(u32)) !bool {
    if (std.sort.isSorted(u32, numbers.items, {}, std.sort.asc(u32))) {
        for (0..numbers.items.len - 1) |i| {
            if (numbers.items[i + 1] - numbers.items[i] > 3 or numbers.items[i + 1] - numbers.items[i] < 1) return false;
        }
    } else if (std.sort.isSorted(u32, numbers.items, {}, std.sort.desc(u32))) {
        for (0..numbers.items.len - 1) |i| {
            if (numbers.items[i] - numbers.items[i + 1] > 3 or numbers.items[i] - numbers.items[i + 1] < 1) return false;
        }
    } else {
        return false;
    }
    return true;
}
