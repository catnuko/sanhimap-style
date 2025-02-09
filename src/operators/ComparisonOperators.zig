const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;
const CallExpr = exp.CallExpr;
const string = @import("../string.zig");
const Tag = @import("../json.zig").Tag;
const log = @import("../console.zig");
fn compare(context: *ExprEvaluatorContext, call: *CallExpr) Value {
    const left = context.evaluate(call.args.items[0]);
    const right = context.evaluate(call.args.items[1]);

    if (@intFromEnum(left) == Tag.float and @intFromEnum(right) == Tag.float) {
        var res: bool = false;
        if (string.eql(call.op, "<")) {
            res = left.float < right.float;
        } else if (string.eql(call.op, "<=")) {
            res = left.float <= right.float;
        } else if (string.eql(call.op, ">")) {
            res = left.float > right.float;
        } else if (string.eql(call.op, ">=")) {
            res = left.float >= right.float;
        } else if (string.eql(call.op, "==")) {
            res = left.float == right.float;
        } else if (string.eql(call.op, "!=")) {
            res = left.float != right.float;
        } else {
            log.panic("invalid comparison operator '{s}'\n", .{call.op});
        }
        return .{ .bool = res };
    }
    if (@intFromEnum(left) == Tag.integer and @intFromEnum(right) == Tag.integer) {
        var res: bool = false;
        if (string.eql(call.op, "<")) {
            res = left.integer < right.integer;
        } else if (string.eql(call.op, "<=")) {
            res = left.integer <= right.integer;
        } else if (string.eql(call.op, ">")) {
            res = left.integer > right.integer;
        } else if (string.eql(call.op, ">=")) {
            res = left.integer >= right.integer;
        } else if (string.eql(call.op, "==")) {
            res = left.integer == right.integer;
        } else if (string.eql(call.op, "!=")) {
            res = left.integer != right.integer;
        } else {
            log.panic("invalid comparison operator '{s}'\n", .{call.op});
        }
        return .{ .bool = res };
    }
    log.panic("invalid operands\n", .{});
}

pub const ComparisonOperators = [_]OperatorDescriptor{
    .{
        .name = "!",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const arg = context.evaluate(call.args.items[0]);
                return .{ .bool = !arg.bool };
            }
        }.func,
    },
    .{
        .name = "==",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                return compare(context, call);
            }
        }.func,
    },
    .{
        .name = "!=",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                return compare(context, call);
            }
        }.func,
    },
    .{
        .name = "<",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                return compare(context, call);
            }
        }.func,
    },
    .{
        .name = ">",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                return compare(context, call);
            }
        }.func,
    },
    .{
        .name = "<=",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                return compare(context, call);
            }
        }.func,
    },
    .{
        .name = ">=",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                return compare(context, call);
            }
        }.func,
    },
};
