const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const log = @import("../console.zig");
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;

pub const CastOperators = [_]OperatorDescriptor{
    .{
        .name = "to-boolean",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *Expr) Value {
                return if (context.evaluate(call.args[0]).bool) true else false;
            }
        }.func,
    },
    .{
        .name = "to-string",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *Expr) Value {
                return context.evaluate(call.args[0]).string;
            }
        }.func,
    },
    .{
        .name = "to-number",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *Expr) Value {
                for (call.args) |arg| {
                    const value = context.evaluate(arg).number;
                    if (value != null) {
                        return value;
                    }
                }
                log.panic("cannot convert the value to a number");
            }
        }.func,
    },
};
