const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    const allocator = std.heap.page_allocator;
    var buf: [100000]u8 = undefined;
    var res1: u64 = 0;
    var res2: u64 = 0;
    var enabled = true;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        for (line, 0..) |_, i| {
            if (std.mem.startsWith(u8, line[i..], "do()")) {
                enabled = true;
            } else if (std.mem.startsWith(u8, line[i..], "don't()")) {
                enabled = false;
            } else if (std.mem.startsWith(u8, line[i..], "mul(")) {
                var first_string_builder = std.ArrayList(u8).init(allocator);
                var second_string_builder = std.ArrayList(u8).init(allocator);
                defer first_string_builder.deinit();
                defer second_string_builder.deinit();
                var first_number: u32 = 0;
                var second_number: u32 = 0;
                var building_first = true;
                // DFA that checks if it matches the regex mul(number,number)
                for (line[i + 4 ..]) |c| {
                    if (c == ',' and first_string_builder.items.len > 0) {
                        for (first_string_builder.items) |num_char| {
                            if (num_char > 47 and num_char < 58) {
                                first_number = first_number * 10 + (num_char - 48);
                            }
                        }
                        first_string_builder.clearAndFree();
                        building_first = false;
                    } else if (c == ')' and second_string_builder.items.len > 0) {
                        for (second_string_builder.items) |num_char| {
                            if (num_char > 47 and num_char < 58) {
                                second_number = second_number * 10 + (num_char - 48);
                            }
                        }
                        const wrap_multiplication = first_number *% second_number;
                        second_string_builder.clearAndFree();
                        res1 += wrap_multiplication;
                        if (enabled) {
                            res2 += wrap_multiplication;
                        }
                    } else if (std.ascii.isDigit(c) and building_first) {
                        try first_string_builder.append(c);
                    } else if (std.ascii.isDigit(c) and !building_first) {
                        try second_string_builder.append(c);
                    } else {
                        break;
                    }
                }
            }
        }
    }
    std.debug.print("Part 1: {d}\n", .{res1});
    std.debug.print("Part 2: {d}\n", .{res2});
}
