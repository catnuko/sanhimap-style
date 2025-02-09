const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;
const Tag = @import("../json.zig").Tag;
const CallExpr = exp.CallExpr;
const log = @import("../console.zig");
fn conditionalCast(context: *ExprEvaluatorContext, ttype: []const u8, args: []Expr) Value {
    if (std.mem.eql(u8, ttype, "boolean")) {
        for (args) |childExpr| {
            const value = context.evaluate(childExpr);
            if (@intFromEnum(value) == Tag.bool) {
                return value;
            }
        }
        return log.panic("expected a boolean", .{});
    } else if (std.mem.eql(u8, ttype, "number")) {
        for (args) |childExpr| {
            const value = context.evaluate(childExpr);
            if (@intFromEnum(value) == Tag.float) {
                return value;
            }
        }
        return log.panic("expected a number", .{});
    } else if (std.mem.eql(u8, ttype, "string")) {
        for (args) |childExpr| {
            const value = context.evaluate(childExpr);
            if (@intFromEnum(value) == Tag.string) {
                return value;
            }
        }
        return log.panic("expected a string", .{});
    } else {
        return log.panic("invalid type", .{});
    }
}
pub const FlowOperators = [_]OperatorDescriptor{
    .{
        .name = "all",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                for (call.args.items) |childExpr| {
                    if (!context.evaluate(childExpr).bool) {
                        return .{ .bool = false };
                    }
                }
                return .{ .bool = true };
            }
        }.func,
    },
    .{
        .name = "any",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                for (call.args.items) |childExpr| {
                    if (context.evaluate(childExpr).bool) {
                        return .{ .bool = true };
                    }
                }
                return .{ .bool = false };
            }
        }.func,
    },
    .{
        .name = "none",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                for (call.args.items) |childExpr| {
                    if (context.evaluate(childExpr).bool) {
                        return .{ .bool = false };
                    }
                }
                return .{ .bool = true };
            }
        }.func,
    },
    .{
        .name = "string",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                return conditionalCast(context, "string", call.args.items);
            }
        }.func,
    },
    .{
        .name = "number",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                return conditionalCast(context, "number", call.args.items);
            }
        }.func,
    },
    .{
        .name = "boolean",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                return conditionalCast(context, "boolean", call.args.items);
            }
        }.func,
    },
};
