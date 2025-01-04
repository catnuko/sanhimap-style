const std = @import("std");
const json = std.json;
const testing = std.testing;
const console = @import("./console.zig");

pub fn parseJson(allocator: std.mem.Allocator, input: []const u8) !json.Value {
    var parser = json.Parser.init(allocator, false);
    defer parser.deinit();

    var tree = try parser.parse(input);
    defer tree.deinit();

    return convertAllNumbersToFloat(allocator, tree.root);
}

fn convertAllNumbersToFloat(allocator: std.mem.Allocator, value: json.Value) !json.Value {
    switch (value) {
        .Integer => |i| return json.Value{ .Float = @floatFromInt(i) },
        .Float => return value,
        .Object => |o| {
            var new_object = json.ObjectMap.init(allocator);
            var it = o.iterator();
            while (it.next()) |entry| {
                const new_value = try convertAllNumbersToFloat(allocator, entry.value_ptr.*);
                try new_object.put(entry.key_ptr.*, new_value);
            }
            return json.Value{ .Object = new_object };
        },
        .Array => |a| {
            var new_array = std.ArrayList(json.Value).init(allocator);
            for (a.items) |item| {
                const new_item = try convertAllNumbersToFloat(allocator, item);
                try new_array.append(new_item);
            }
            return json.Value{ .Array = new_array };
        },
        else => return value,
    }
}
pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const json_string =
        \\{"integer": 42, "float": 3.14, "nested": {"array": [1, 2, 3]}}
    ;
    var value = try parseJson(allocator, json_string);
    defer value.deinit();

    std.debug.print("{}\n", .{value});
}
