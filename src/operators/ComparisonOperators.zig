const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;
const CallExpr = exp.CallExpr;
const string = @import("./string.zig");
const log = @import("./console.zig");
fn compare(context: *ExprEvaluatorContext, call: *CallExpr, strict: bool) Value {
    const left = context.evaluate(call.args[0]);
    const right = context.evaluate(call.args[1]);

    if (!((left == .{ .number = null }) and (right == .{ .number = null })) or
        (left == .{ .string = null }) and (right == .{ .string = null }))
    {
        if (strict) {
            return Value.initError("invalid operands");
        }
    }

    if (string.eql(call.op, "<")) {
        return left < right;
    } else if (string.eql(call.op, "<=")) {
        return left <= right;
    } else if (string.eql(call.op, ">")) {
        return left > right;
    } else if (string.eql(call.op, ">=")) {
        return left >= right;
    } else if (string.eql(call.op, "==")) {
        return left == right;
    } else if (string.eql(call.op, "!=")) {
        return left != right;
    } else {
        log.panic("invalid comparison operator '{s}'\n", .{call.op});
    }
}

pub const ComparisonOperators = [_]OperatorDescriptor{
    .{
        .name = "!",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const arg = context.evaluate(call.args[0]);
                return !arg.bool;
            }
        }.func,
    },
    .{
        .name = "==",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                return compare(context, call, false);
            }
        }.func,
    },
    .{
        .name = "!=",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                return compare(context, call, false);
            }
        }.func,
    },
    .{
        .name = "<",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                return compare(context, call, true);
            }
        }.func,
    },
    .{
        .name = ">",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                return compare(context, call, true);
            }
        }.func,
    },
    .{
        .name = "<=",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *Expr) Value {
                return compare(context, call, true);
            }
        }.func,
    },
    .{
        .name = ">=",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *Expr) Value {
                return compare(context, call, true);
            }
        }.func,
    },
};
