const std = @import("std");
const json = std.json;
const testing = std.testing;
const console = @import("./console.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const json_str =
        \\{
        \\  "userid": 103609,
        \\  "verified": true,
        \\  "access_privileges": [
        \\    "你好",
        \\    "admin",
        \\     3
        \\  ]
        \\}
    ;
    const P = json.Value;
    const T = struct { userid: i32, verified: bool, access_privileges: []P };
    const parsed = try json.parseFromSlice(T, allocator, json_str, .{});
    defer parsed.deinit();

    const value = parsed.value;
    std.debug.print("{any}\n", .{value});
    // try testing.expect(value.userid == 103609);
    // try testing.expect(value.verified);
    // try testing.expectEqualStrings("你好", value.access_privileges[0]);
    // try testing.expectEqualStrings("admin", value.access_privileges[1]);

    // // Serialize JSON
    // value.verified = false;
    // const new_json_str = try json.stringifyAlloc(allocator, value, .{ .whitespace = .indent_2 });
    // defer allocator.free(new_json_str);

    // try testing.expectEqualStrings(
    //     \\{
    //     \\  "userid": 103609,
    //     \\  "verified": false,
    //     \\  "access_privileges": [
    //     \\    "你好",
    //     \\    "admin"
    //     \\  ]
    //     \\}
    // ,
    //     new_json_str,
    // );
}
