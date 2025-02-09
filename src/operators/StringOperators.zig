const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const string = @import("../string.zig");
const log = @import("../console.zig");
const alloc = @import("../alloc.zig");
const VALID_ELEMENT_TYPES = [_][]const u8{ "boolean", "number", "string" };
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const Tag = @import("../json.zig").Tag;
const String = @import("string").String;
const Expr = exp.Expr;
pub const StringOperators = [_]OperatorDescriptor{
    .{
        .name = "concat",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                var res = String.init(alloc.get());
                for (call.args.items) |arg| {
                    const value = context.evaluate(arg);
                    if (@intFromEnum(value) != Tag.string) {
                        log.panic("expected a string\n", .{});
                    }
                    res.concat(value.string) catch unreachable;
                }
                //TODO free string
                return .{ .string = (res.toOwned() catch unreachable) orelse unreachable };
            }
        }.func,
    },
    .{
        .name = "downcase",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                var res = String.init(alloc.get());
                res.concat(context.evaluate(call.args.items[0]).string) catch unreachable;
                res.toLowercase();
                return .{ .string = (res.toOwned() catch unreachable) orelse unreachable };
            }
        }.func,
    },
    .{
        .name = "upcase",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                var res = String.init(alloc.get());
                res.concat(context.evaluate(call.args.items[0]).string) catch unreachable;
                res.toUppercase();
                return .{ .string = (res.toOwned() catch unreachable) orelse unreachable };
            }
        }.func,
    },
    .{
        .name = "~=",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                const left = context.evaluate(call.args.items[0]);
                const right = context.evaluate(call.args.items[1]);
                if (@intFromEnum(left) != Tag.string or @intFromEnum(right) != Tag.string) {
                    return .{ .bool = false };
                }
                return .{ .bool = string.includes(left.string, right.string) };
            }
        }.func,
    },
    .{
        .name = "^=",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                const left = context.evaluate(call.args.items[0]);
                const right = context.evaluate(call.args.items[1]);
                if (@intFromEnum(left) != Tag.string or @intFromEnum(right) != Tag.string) {
                    return .{ .bool = false };
                }
                return .{ .bool = string.startsWith(left.string, right.string) };
            }
        }.func,
    },
    .{
        .name = "$=",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                const left = context.evaluate(call.args.items[0]);
                const right = context.evaluate(call.args.items[1]);
                if (@intFromEnum(left) != Tag.string or @intFromEnum(right) != Tag.string) {
                    return .{ .bool = false };
                }
                return .{ .bool = string.endsWith(left.string, right.string) };
            }
        }.func,
    },
};
