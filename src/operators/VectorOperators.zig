const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const string = @import("../string.zig");
const mem = @import("../mem.zig");
const log = @import("../console.zig");
const alloc = @import("../alloc.zig");
const VALID_ELEMENT_TYPES = [_][]const u8{ "boolean", "number", "string" };
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;
const math = @import("math");
const Vector2D = math.Vector2D;
const Vector3D = math.Vector3D;
const Vector4D = math.Vector4D;
pub const MakedVector = union(enum) {
    vec2: Vector2D,
    vec3: Vector3D,
    vec4: Vector4D
};
pub fn isVector()Value{

}
pub const VectorOperators = [_]OperatorDescriptor{
    .{
        .name = "make-vector",
        .call = struct {
            fn func(context: ExprEvaluatorContext, call: *exp.CallExpr) Value {
                //TODO check MakeVectorCallExpr
                if (call.args.items.len < 2) {
                    log.panic("not enough arguments\n", .{});
                } else if (call.args.items.len > 4) {
                    log.panic("too many arguments\n", .{});
                }
                var array = std.ArrayList(f64).init(alloc.get());
                for (call.args.items, 0..) |arg, index| {
                    const value = context.evaluate(arg);
                    if (@TypeOf(value) != .float) {
                        log.panic("expected vector component at index {} to have type \"number\"\n", .{index});
                    }
                    array.append(value.float) catch unreachable;
                }
                var result:MakedVector = undefined;
                if (array.items.len == 2) {
                    result = .{.vec2 = Vector2D.init(array.items[0], array.items[1])};
                } else if (array.items.len == 3) {
                    result = .{.vec3 = Vector3D.init(array.items[0], array.items[1], array.items[2])};
                } else if (array.items.len == 4) {
                    result = .{.vec4 = Vector4D.init(array.items[0], array.items[1], array.items[2], array.items[3])};
                } else {
                    log.panic("too many arguments\n", .{});
                }
                return result;
            }
        }.func,
    },
    .{
        .name = "vector2",
        .call = struct {
            fn func(_: ExprEvaluatorContext, _: *exp.CallExpr) Value {
                log.panic("not implemented", .{});
            }
        }
    },
    .{
        .name = "vector3",
        .call = struct {
            fn func(_: ExprEvaluatorContext, _: *exp.CallExpr) Value {
                log.panic("not implemented", .{});
            }
        }
    },
    .{
        .name = "vector4",
        .call = struct {
            fn func(_: ExprEvaluatorContext, _: *exp.CallExpr) Value {
                log.panic("not implemented", .{});
            }
        }
    },
    .{
        .name = "to-vector2",
        .call = struct {
            fn func(_: ExprEvaluatorContext, _: *exp.CallExpr) Value {
                log.panic("not implemented", .{});
            }
        }
    },
    .{
        .name = "to-vector3",
        .call = struct {
            fn func(_: ExprEvaluatorContext, _: *exp.CallExpr) Value {
                log.panic("not implemented", .{});
            }
        }
    },
    .{
        .name = "to-vector4",
        .call = struct {
            fn func(_: ExprEvaluatorContext, _: *exp.CallExpr) Value {
                log.panic("not implemented", .{});
            }
        }
    },
};
