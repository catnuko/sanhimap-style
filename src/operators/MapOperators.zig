const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;
const CallExpr = exp.CallExpr;

pub const MapOperators = [_]OperatorDescriptor{
    .{
        .name = "ppi-scale",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const pixels = context.evaluate(call.args[0]);
                const scaleFactor = if (call.args.len > 1) context.evaluate(call.args[1]) else 1;
                const zoom = context.env.lookup("$zoom");
                const zoomWidth = std.math.pow(2, 17) / std.math.pow(2, zoom);
                const v = pixels * zoomWidth * scaleFactor;
                return .{ .number = v };
            }
        }.func,
    },
    .{
        .name = "zoom",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, _: *CallExpr) Value {
                const zoom = context.env.lookup("$zoom");
                return .{ .number = zoom };
            }
        }.func,
    },
    .{
        .name = "world-ppi-scale",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const pixels = context.evaluate(call.args[0]);
                const scaleFactor = if (call.args.len > 1) context.evaluate(call.args[1]) else 1;
                const zoom = context.env.lookup("$zoom");
                const zoomWidth = std.math.pow(2, 17) / std.math.pow(2, zoom);
                const v = pixels * zoomWidth * scaleFactor;
                return .{ .number = v };
            }
        }.func,
    },
    .{
        .name = "world-discrete-ppi-scale",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const pixels = context.evaluate(call.args[0]);
                const scaleFactor = if (call.args.len > 1) context.evaluate(call.args[1]) else 1;
                const zoom = context.env.lookup("$zoom");
                const zoomWidth = std.math.pow(2, 17) / std.math.pow(2, zoom);
                const v = pixels * zoomWidth * scaleFactor;
                return .{ .number = v };
            }
        }.func,
    },
    .{
        .name = "ppi",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const pixels = context.evaluate(call.args[0]);
                return .{ .number = pixels };
            }
        }.func,
    },
};
