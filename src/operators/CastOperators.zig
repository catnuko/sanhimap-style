const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const log = @import("../console.zig");
const Tag = @import("../json.zig").Tag;
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;

pub const CastOperators = [_]OperatorDescriptor{
    .{
        .name = "to-boolean",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                return if (context.evaluate(call.args.items[0]).bool) .{ .bool = true } else .{ .bool = false };
            }
        }.func,
    },
    .{
        .name = "to-string",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                return context.evaluate(call.args.items[0]);
            }
        }.func,
    },
    .{
        .name = "to-number",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                for (call.args.items) |arg| {
                    const value = context.evaluate(arg);
                    if (@intFromEnum(value) != Tag.null) {
                        return value;
                    }
                }
                log.panic("cannot convert the value to a number",.{});
            }
        }.func,
    },
};
