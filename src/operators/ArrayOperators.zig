const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const string = @import("../string.zig");
const Tag = @import("../json.zig").Tag;
const log = @import("../console.zig");
const alloc = @import("../alloc.zig");
const VALID_ELEMENT_TYPES = [_][]const u8{ "bool", "float", "integer", "string" };
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;

fn checkElementTypes(arg: Expr, array: std.json.Array) void {
    if (@intFromEnum(arg) != exp.ExprTag.stringLiteral or !string.includesOfStrings(&VALID_ELEMENT_TYPES, arg.stringLiteral.value)) {
        log.panic("expected \"boolean\", \"number\" or \"string\" instead of {any}\n", .{arg.value()});
    }
    const ty = arg.stringLiteral.value;
    for (array.items, 0..) |item, index| {
        if (!string.eql(@tagName(item), ty)) {
            log.panic("expected array element at index {any} to have type {any}\n", .{ index, ty });
        }
    }
}
fn checkArray(context: *ExprEvaluatorContext, arg: Expr) Value {
    const value = context.evaluate(arg);
    if (@intFromEnum(value) != Tag.array) {
        log.panic("'{any}' is not an array\n", .{value});
    }
    return value;
}
fn checkArrayLength(arg: Expr, array: std.json.Array) void {
    if (@intFromEnum(arg) != exp.ExprTag.numberLiteral) {
        log.panic("missing expected number of elements\n", .{});
    }
    const length = arg.numberLiteral.value;
    if (length != @as(f64, @floatFromInt(array.items.len))) {
        log.panic("the array must have ${} element(s)\n", .{length});
    }
}
pub const ArrayOperators = [_]OperatorDescriptor{
    .{
        .name = "array",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                switch (call.args.items.len) {
                    0 => {
                        @panic("not enough arguments");
                    },
                    1 => {
                        return checkArray(context, call.args.items[0]);
                    },
                    2 => {
                        const array = checkArray(context, call.args.items[0]);
                        checkElementTypes(call.args.items[0], array.array);
                        return array;
                    },
                    3 => {
                        const array = checkArray(context, call.args.items[2]);
                        checkArrayLength(call.args.items[1], array.array);
                        checkElementTypes(call.args.items[0], array.array);
                        return array;
                    },
                    else => {
                        log.panic("too many arguments\n", .{});
                    },
                }
            }
        }.func,
    },
    .{
        .name = "make-array",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                if (call.args.items.len == 0) {
                    log.panic("not enough arguments\n", .{});
                }
                var array = std.ArrayList(Value).init(alloc.get());
                for (call.args.items) |arg| {
                    array.append(context.evaluate(arg)) catch unreachable;
                }
                return .{ .array = array };
            }
        }.func,
    },
    .{
        .name = "at",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                const args = call.args;
                const index = context.evaluate(args.items[0]);
                if (@intFromEnum(index) != Tag.integer) {
                    log.panic("expected the index of the element to retrieve\n", .{});
                }
                const value = context.evaluate(args.items[1]);
                if (@intFromEnum(value) != Tag.array) {
                    log.panic("expected an array\n", .{});
                }
                const i: usize = @intCast(index.integer);
                return if (i > 0 and i < value.array.items.len) value.array.items[i] else .null;
            }
        }.func,
    },
    .{
        .name = "slice",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                if (call.args.items.len < 2) {
                    log.panic("not enough arguments\n", .{});
                }
                const input = context.evaluate(call.args.items[0]);
                if (!(@intFromEnum(input) == Tag.string or @intFromEnum(input) == Tag.array)) {
                    log.panic("input must be a string or an array\n", .{});
                }
                const start = context.evaluate(call.args.items[1]);
                if (!(@intFromEnum(start) == Tag.integer)) {
                    log.panic("expected an index\n", .{});
                }
                var end: Value = undefined;
                if (call.args.items.len > 2) {
                    end = context.evaluate(call.args.items[2]);
                    if (@intFromEnum(end) != Tag.integer) {
                        log.panic("expected an index\n", .{});
                    }
                }
                var array = std.ArrayList(Value).init(alloc.get());
                array.appendSlice(input.array.items[@intCast(start.integer)..@intCast(end.integer)]) catch unreachable;
                return .{ .array = array };
            }
        }.func,
    },
};
