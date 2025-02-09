const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const Tag = @import("../json.zig").Tag;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;
const CallExpr = exp.CallExpr;
const log = @import("../console.zig");
const String = std.ArrayList(u8);
const StringList = std.ArrayList(String);
pub fn destroyjoinedCombinations(allocator: std.mem.Allocator, stringList: *StringList) void {
    for (stringList.items) |item| {
        allocator.free(item);
    }
    stringList.deinit();
}
pub fn joinCombinations(allocator: std.mem.Allocator, combinations: StringList) StringList {
    std.mem.sort(String, &combinations, {}, struct {
        fn compare(_: void, a: String, b: String) bool {
            return a.len < b.len;
        }
    }.compare);
    var result = StringList.init(allocator);
    for (combinations) |keys| {
        const joinedKeys = std.mem.join(allocator, "&", keys) catch unreachable;
        result.append(joinedKeys) catch unreachable;
    }
    const v = allocator.alloc(u8, 1) catch unreachable;
    v.* = "";
    result.push(v);
    return result;
}

pub fn getAllCombinations(allocator: std.mem.Allocator, input: StringList, index: usize) std.ArrayList(StringList) {
    if (index > input.items.len) {
        return std.ArrayList(StringList).init(allocator);
    }
    var combinations = getAllCombinations(allocator, input, index + 1);
    const initLength = combinations.items.len;
    for (0..initLength) |i| {
        var newStringList = StringList.init(allocator);
        newStringList.appendSlice(combinations.items[i]);
        newStringList.append(input[index]) catch unreachable;
        combinations.append(newStringList) catch unreachable;
    }
    var newStringList = StringList.init(allocator);
    newStringList.append(input[index]) catch unreachable;
    combinations.append(newStringList) catch unreachable;
    return combinations;
}
fn stringifyKeyValue(allocator: std.mem.Allocator, _: String, value: Value) String {
    var string = std.ArrayList(u8).init(allocator);
    std.json.stringify(value, .{}, string.writer()) catch unreachable;
    return string;
}
pub fn getKeyCombinations(allocator: std.mem.Allocator, lookupExpr: *exp.LookupExpr, context: *ExprEvaluatorContext) []String {
    const keys = lookupExpr.callExpr.args.items[1..];
    var result = std.ArrayList(String).init(allocator);

    for (0..keys.len) |i| {
        const value = context.evaluate(keys[i + 1]);
        if (value == null) {
            continue;
        }
        const key = context.evaluate(keys[i]);
        result.append(stringifyKeyValue(allocator, key, value)) catch unreachable;
    }
    //descending
    std.mem.sort(String, result.items, {}, struct {
        fn compare(_: void, a: String, b: String) bool {
            return a.len > b.len;
        }
    }.compare);
    return joinCombinations(allocator, getAllCombinations(allocator, result, 0));
}

pub fn searchLookupMap(keys: []String, map: *std.json.ObjectMap) ?std.json.ObjectMap {
    for (keys) |key| {
        const matchAttributes = map.get(key);
        if (matchAttributes) |attributes| {
            return attributes;
        }
    }
    return null;
}

pub const MiscOperators = [_]OperatorDescriptor{
    .{
        .name = "length",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args.items[0]);
                if (@intFromEnum(a) != Tag.string) {
                    log.panic("invalid operands '{any}' for operator 'length'\n", .{a});
                }
                return .{ .integer = @intCast(a.string.len) };
            }
        }.func,
    },
    .{
        .name = "lookup",
        .call = struct {
            fn func(_: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                if (call.args.items.len == 0) {
                    log.panic("missing lookup table\n", .{});
                }
                const keys = call.args.items[0];
                const map = call.args.items[1];
                if (@intFromEnum(keys) != Tag.array or @intFromEnum(map) != Tag.object) {
                    log.panic("invalid operands '{any}' and '{any}' for operator 'lookup'\n", .{ keys, map });
                }
                const result = searchLookupMap(keys.array, map.object);
                return if (result) |r| .{ .object = r } else .null;
            }
        }.func,
    },
    .{
        .name = "coalesce",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                for (call.args.items) |arg| {
                    const value = context.evaluate(arg);
                    if (@intFromEnum(value) != Tag.null) {
                        return value;
                    }
                }
                return .null;
            }
        }.func,
    },
};
