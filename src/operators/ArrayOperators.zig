const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const string = @import("../string.zig");
const mem = @import("../mem.zig");
const console = @import("../console.zig");
const VALID_ELEMENT_TYPES = [_][]const u8{ "boolean", "number", "string" };
fn checkElementTypes(arg: Expr, array: Value.Array) void {
    if (!(arg.getType() == "StringLiteralExpr") or !mem.includes(&VALID_ELEMENT_TYPES, arg.value())) {
        console.panic("expected \"boolean\", \"number\" or \"string\" instead of {any}", .{arg.value()});
    }
    const ty = arg.value();
    for (array.items, 0..) |item, index| {
        if (std.mem.eql(u8, @typeName(@TypeOf(element)), ty)) {
            console.panic("expected array element at index {any} to have type {any}", .{ index, ty });
        }
    }
}

fn checkArray(context: ExprEvaluatorContext, arg: Expr) Value {}
pub const ArrayOperators = [_]OperatorDescriptor{
    .{
        .name = "array",
        .call = fn (context: ExprEvaluatorContext, call: CallExpr) Value{switch (call.args.len) {
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
                console.panic("too many arguments", .{});
            },
        }},
    },
    .{
        .name = "make-array",
        .call = fn (context: ExprEvaluatorContext, call: CallExpr) Value{},
    },
    .{
        .name = "at",
        .call = fn (context: ExprEvaluatorContext, call: CallExpr) Value{},
    },
    .{
        .name = "slice",
        .call = fn (context: ExprEvaluatorContext, call: CallExpr) Value{},
    },
};
