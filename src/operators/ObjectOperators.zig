const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const string = @import("../string.zig");

const log = @import("../console.zig");
const alloc = @import("../alloc.zig");
const MapEnv = @import("../Env.zig").MapEnv;
const Tag = @import("../json.zig").Tag;
const VALID_ELEMENT_TYPES = [_][]const u8{ "boolean", "number", "string" };
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;
const LookupMode = enum {
    get,
    has,
};
fn lookupMember(context: *ExprEvaluatorContext, args: *std.ArrayList(Expr), lookupMode: LookupMode) bool {
    const memberName = context.evaluate(args.items[0]);

    if (@intFromEnum(memberName) != Tag.string) {
        log.panic("expected the name of an attribute\n", .{});
    }

    const object = context.evaluate(args.items[1]);
    if (@intFromEnum(object) == Tag.object) {
        if (MapEnv.isEnv(object)) {
            const value = object.object.lookup(memberName) orelse null;
            return if (lookupMode == LookupMode.get) value else value != Tag.null;
        }

        if (object.object.contains(memberName)) {
            return if (lookupMode == LookupMode.get) object.object.get(memberName) else true;
        }
    }

    return if (lookupMode == LookupMode.get) null else false;
}
pub const ObjectOperators = [_]OperatorDescriptor{
    .{
        .name = "in",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                const value = context.evaluate(call.args.items[0]);
                const object = context.evaluate(call.args.items[1]);
                if (@intFromEnum(value) == Tag.string and @intFromEnum(object) == Tag.string) {
                    return .{ .bool = string.includes(object.string, value.string) };
                } else if (@intFromEnum(object) == Tag.array) {
                    var getit = false;
                    for (object.array.items) |item| {
                        //TODO 判断两个value是否相同
                        if (item == value) {
                            getit = true;
                        }
                    }
                    return .{ .bool = getit };
                }
                return .{ .bool = false };
            }
        }.func,
    },
    .{
        .name = "get",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                return .{ .bool = lookupMember(context, &call.args, LookupMode.get) };
            }
        }.func,
    },
    .{
        .name = "has",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                return .{ .bool = lookupMember(context, &call.args, LookupMode.has) };
            }
        }.func,
    },
    .{
        .name = "dynamic-properties",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                if (context.scope == exp.ExprScope.Dynamic) {
                    return context.env;
                }
                return call;
            }
        }.func,
    },
};
