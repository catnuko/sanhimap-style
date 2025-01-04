const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;
const CallExpr = exp.CallExpr;
const log = @import("../console.zig");
fn conditionalCast(context: *ExprEvaluatorContext, ttype: []const u8, args: []Expr) Value {
    if (std.mem.eql(u8, ttype, "boolean")) {
        for (args) |childExpr| {
            const value = context.evaluate(childExpr);
            if (@TypeOf(value) == .bool) {
                return value;
            }
        }
        return log.panic("expected a boolean");
    } else if (std.mem.eql(u8, ttype, "number")) {
        for (args) |childExpr| {
            const value = context.evaluate(childExpr);
            if (@TypeOf(value) == .float) {
                return value;
            }
        }
        return log.panic("expected a number");
    } else if (std.mem.eql(u8, ttype, "string")) {
        for (args) |childExpr| {
            const value = context.evaluate(childExpr);
            if (@TypeOf(value) == .string) {
                return value;
            }
        }
        return log.panic("expected a string");
    } else {
        return log.panic("invalid type");
    }
}
pub const FlowOperators = [_]OperatorDescriptor{
    .{
        .name = "all",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) bool {
                for (call.args) |childExpr| {
                    if (!context.evaluate(childExpr).bool) {
                        return Value.initBool(false);
                    }
                }
                return true;
            }
        }.func,
    },
    .{
        .name = "any",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) bool {
                for (call.args) |childExpr| {
                    if (context.evaluate(childExpr).bool) {
                        return true;
                    }
                }
                return false;
            }
        }.func,
    },
    .{
        .name = "none",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) bool {
                for (call.args) |childExpr| {
                    if (context.evaluate(childExpr).bool) {
                        return false;
                    }
                }
                return true;
            }
        }.func,
    },
    .{
        .name = "string",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                return conditionalCast(context, "string", call.args);
            }
        }.func,
    },
    .{
        .name = "number",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                return conditionalCast(context, "number", call.args);
            }
        }.func,
    },
    .{
        .name = "boolean",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                return conditionalCast(context, "boolean", call.args);
            }
        }.func,
    },
};
