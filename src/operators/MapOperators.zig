const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const log = @import("../console.zig");
const Expr = exp.Expr;
const CallExpr = exp.CallExpr;

pub const MapOperators = [_]OperatorDescriptor{
    .{
        .name = "ppi-scale",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const pixels = context.evaluate(call.args.items[0]);
                const scaleFactor = if (call.args.items.len > 1) context.evaluate(call.args.items[1]) else Value{ .float = 1.0 };
                const zoom = context.env.lookup("$zoom");
                const zoomWidth = std.math.pow(f64, 2.0, 17.0) / std.math.pow(f64, 2.0, zoom.?.float);
                const v = pixels.float * zoomWidth * scaleFactor.float;
                return .{ .float = v };
            }
        }.func,
    },
    .{
        .name = "zoom",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, _: *CallExpr) Value {
                const zoom = context.env.lookup("$zoom");
                if (zoom) |z| {
                    return z;
                } else {
                    log.panic("zoom not set", .{});
                }
            }
        }.func,
    },
    .{
        .name = "world-ppi-scale",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const pixels = context.evaluate(call.args.items[0]);
                const scaleFactor = if (call.args.items.len > 1) context.evaluate(call.args.items[1]) else Value{ .float = 1.0 };
                const zoom = context.env.lookup("$zoom");
                const zoomWidth = std.math.pow(f64, 2, 17) / std.math.pow(f64, 2, zoom.?.float);
                const v = pixels.float * zoomWidth * scaleFactor.float;
                return .{ .float = v };
            }
        }.func,
    },
    .{
        .name = "world-discrete-ppi-scale",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const pixels = context.evaluate(call.args.items[0]);
                const scaleFactor = if (call.args.items.len > 1) context.evaluate(call.args.items[1]) else Value{ .float = 1.0 };
                const zoom = context.env.lookup("$zoom");
                const zoomWidth = std.math.pow(f64, 2, 17) / std.math.pow(f64, 2, zoom.?.float);
                const v = pixels.float * zoomWidth * scaleFactor.float;
                return .{ .float = v };
            }
        }.func,
    },
    .{
        .name = "ppi",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const pixels = context.evaluate(call.args.items[0]);
                return .{ .float = pixels.float };
            }
        }.func,
    },
};
