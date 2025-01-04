const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const string = @import("../string.zig");
const mem = @import("../mem.zig");
const log = @import("../console.zig");
const alloc = @import("../alloc.zig");
const VALID_ELEMENT_TYPES = [_][]const u8{ "boolean", "number", "string" };
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;
fn checkElementTypes(arg: Expr, array: Value.Array) void {
    if (!string.eql(arg.m_typeName, "StringLiteralExpr") or !mem.includes(&VALID_ELEMENT_TYPES, arg.value())) {
        log.panic("expected \"boolean\", \"number\" or \"string\" instead of {any}\n", .{arg.value()});
    }
    const ty = arg.asStringLiteralExpr().value;
    for (array.items, 0..) |item, index| {
        if (string.eql(@typeName(@TypeOf(item)), ty)) {
            log.panic("expected array element at index {any} to have type {any}\n", .{ index, ty });
        }
    }
}
fn checkArray(context: ExprEvaluatorContext, arg: *Expr) Value {
    const value = context.evaluate(arg);
    if (@TypeOf(value) != .array) {
        log.panic("'{any}' is not an array\n", .{value});
    }
    return value;
}
fn checkArrayLength(arg: *Expr, array: std.json.Array) void {
    if (!string.eql(arg.m_typeName, "NumberLiteralExpr")) {
        log.panic("missing expected number of elements\n", .{});
    }
    const length = arg.asNumberLiteralExpr().value;
    if (length != array.items.len) {
        log.panic("the array must have ${} element(s)\n", .{length});
    }
}
pub const ArrayOperators = [_]OperatorDescriptor{
    .{
        .name = "array",
        .call = struct {
            fn func(context: ExprEvaluatorContext, call: *exp.CallExpr) Value {
                switch (call.args.len) {
                    0 => {
                        @panic("not enough arguments");
                    },
                    1 => {
                        return checkArray(context, call.args[0]);
                    },
                    2 => {
                        const array = checkArray(context, call.args[0]);
                        checkElementTypes(call.args[0], array);
                        return array;
                    },
                    3 => {
                        const array = checkArray(context, call.args[2]);
                        checkArrayLength(call.args[1], array);
                        checkElementTypes(call.args[0], array);
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
            fn func(context: ExprEvaluatorContext, call: *exp.CallExpr) Value {
                if (call.args.items.len == 0) {
                    log.panic("not enough arguments\n", .{});
                }
                var array = std.json.Array(Value).init(alloc.get());
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
            fn func(context: ExprEvaluatorContext, call: *exp.CallExpr) Value {
                const args = call.args;
                const index = context.evaluate(args.items[0]);
                if (@TypeOf(index) != .number) {
                    log.panic("expected the index of the element to retrieve\n", .{});
                }
                const value = context.evaluate(args.items[1]);
                if (@TypeOf(value) != .array) {
                    log.panic("expected an array\n", .{});
                }
                return if (index > 0 and index < value.array.items.len) value.array.items[index] else .null;
            }
        }.func,
    },
    .{
        .name = "slice",
        .call = struct {
            fn func(context: ExprEvaluatorContext, call: *exp.CallExpr) Value {
                if (call.args.items.len < 2) {
                    log.panic("not enough arguments\n", .{});
                }
                const input = context.evaluate(call.args.items[0]);
                if (!(@TypeOf(input) == .string or @TypeOf(input) == .array)) {
                    log.panic("input must be a string or an array\n", .{});
                }
                const start = context.evaluate(call.args.items[1]);
                if (!(@TypeOf(start) == .number)) {
                    log.panic("expected an index\n", .{});
                }
                var end: Value = undefined;
                if (call.args.items.len > 2) {
                    end = context.evaluate(call.args.items[2]);
                    if (@TypeOf(end) != .number) {
                        log.panic("expected an index\n", .{});
                    }
                }
                return input.array.items[start.interger..end.integer];
            }
        }.func,
    },
};
