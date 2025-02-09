const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const string = @import("../string.zig");

const Tag = @import("../json.zig").Tag;
const log = @import("../console.zig");
const alloc = @import("../alloc.zig");
const VALID_ELEMENT_TYPES = [_][]const u8{ "boolean", "number", "string" };
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;

pub const TypeOperators = [_]OperatorDescriptor{
    .{
        .name = "in",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                const value = context.evaluate(call.args.items[0]);
                return .{ .string = @typeName(@TypeOf(value)) };
            }
        }.func,
    },
};
