const std = @import("std");
const alloc = @import("../alloc.zig");
const MapEnv = @import("../Env.zig").MapEnv;
const ValueMap = @import("../Env.zig").ValueMap;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;
const string = @import("../string.zig");

const evaluate = @import("./Expr.zig").evaluate;
test "Expr.fromJson" {
    const testing = std.testing;
    alloc.init(testing.allocator);
    defer alloc.deinit();
    // const env = MapEnv.new(ValueMap.init(alloc.get()), null);
    // testing.expect(evaluate("length('foo')", env) == 3);

    var baseDefinitions = exp.Definitions.init(alloc.get());
    defer baseDefinitions.deinit();
    baseDefinitions.put("color", .{ .definition = .{ .value = .{ .string = "#ff0" } } }) catch unreachable;
    baseDefinitions.put("string", .{ .definition = .{ .value = .{ .string = "abc" } } }) catch unreachable;
    baseDefinitions.put("number", .{ .definition = .{ .value = .{ .float = 123 } } }) catch unreachable;
    baseDefinitions.put("number2", .{ .definition = .{ .value = .{ .float = 234 } } }) catch unreachable;
    baseDefinitions.put("boolean", .{ .definition = .{ .value = .{ .bool = true } } }) catch unreachable;

    const json_string =
        \\["ref":"color"]
    ;
    const parsed_json = try std.json.parseFromSlice(std.json.Value, alloc.get(), json_string, .{});
    defer parsed_json.deinit();
    const expr = Expr.fromJson(parsed_json.value, baseDefinitions, null);
    const value = expr.evaluate(null, null);
    try testing.expect(string.eql(value.string, "#ff0"));
}
