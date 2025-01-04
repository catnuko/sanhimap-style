const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const ColorUtils = @import("../ColorUtils.zig");
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;
const ExprScope = exp.ExprScope;
const CallExpr = exp.CallExpr;
const log = @import("../console.zig");
const string = @import("../string.zig");

pub const FeatureOperators = [_]OperatorDescriptor{
    .{
        .name = "geometry-type",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, _: *CallExpr) Value {
                const geometryType = context.env.lookup("$geometryType") orelse .null;
                if (string.eql(geometryType, "point")) {
                    return .{ .string = "Point" };
                } else if (string.eql(geometryType, "line")) {
                    return .{ .string = "Line" };
                } else if (string.eql(geometryType, "polygon")) {
                    return .{ .string = "Polygon" };
                } else {
                    return .null;
                }
            }
        }.func,
    },
    .{
        .name = "feature-state",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                if (context.scope != ExprScope.Dynamic) {
                    return log.panic("feature-state cannot be used in this context\n", .{});
                }
                const property = context.evaluate(call.args[0]);
                if (@TypeOf(property) != .string) {
                    return log.panic("expected the name of the property of the feature state\n", .{});
                }
                const state = context.env.lookup("$state");
                if (state) |s| {
                    return s.get(property);
                } else {
                    return .null;
                }
            }
        }.func,
    },
    .{
        .name = "id",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, _: *CallExpr) Value {
                return context.env.lookup("$id") orelse .null;
            }
        }.func,
    },
};
