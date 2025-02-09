const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const ColorUtils = @import("../ColorUtils.zig");
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;
const Tag = @import("../json.zig").Tag;
const log = @import("../console.zig");
const parseStringEncodedColor = @import("../StringEncodedNumeral.zig").parseStringEncodedColor;
fn rgbaToHex(r: f64, g: f64, b: f64, a: f64) u32 {
    return ColorUtils.getHexFromRgba(std.math.clamp(r, 0.0, 255.0) / 255.0, std.math.clamp(g, 0.0, 255.0) / 255.0, std.math.clamp(b, 0.0, 255.0) / 255.0, std.math.clamp(a, 0.0, 1.0));
}

fn rgbToHex(r: f64, g: f64, b: f64) u32 {
    return ColorUtils.getHexFromRgb(std.math.clamp(r, 0.0, 255.0) / 255.0, std.math.clamp(g, 0.0, 255.0) / 255.0, std.math.clamp(b, 0.0, 255.0) / 255.0);
}

fn hslToHex(h: f64, s: f64, l: f64) u32 {
    return ColorUtils.getHexFromHsl(std.math.euclideanModulo(h, 360.0) / 360.0, std.math.clamp(s, 0.0, 100.0) / 100.0, std.math.clamp(l, 0.0, 100.0) / 100.0);
}

pub const ColorOperators = [_]OperatorDescriptor{
    .{
        .name = "alpha",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                const color: Value = context.evaluate(call.args.items[0]);
                if (@intFromEnum(color) == Tag.string) {
                    const hex = parseStringEncodedColor(color.string) orelse unreachable;
                    return .{ .float = ColorUtils.getAlphaFromHex(hex) };
                }
                return .{ .float = 1.0 };
            }
        }.func,
    },
    .{
        .name = "rgba",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                const r = context.evaluate(call.args.items[0]);
                const g = context.evaluate(call.args.items[1]);
                const b = context.evaluate(call.args.items[2]);
                const a = context.evaluate(call.args.items[3]);
                if (@intFromEnum(r) == Tag.float and @intFromEnum(g) == Tag.float and @intFromEnum(g) == Tag.float and @intFromEnum(b) == Tag.float and
                    r.float >= 0 and g.float >= 0 and b.float >= 0 and a.float >= 0 and a.float <= 1)
                {
                    return .{ .float = rgbaToHex(r.float, g.float, b.float, a.float) };
                }
                log.panic("unknown color 'rgba(${r},${g},${b},${a})'", .{});
            }
        }.func,
    },
    .{
        .name = "rgb",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                const r = context.evaluate(call.args.items[0]);
                const g = context.evaluate(call.args.items[1]);
                const b = context.evaluate(call.args.items[2]);
                if (@intFromEnum(r) == Tag.float and @intFromEnum(g) == Tag.float and @intFromEnum(g) == Tag.float and r.float >= 0 and g.float >= 0 and b.float >= 0) {
                    return .{ .float = rgbToHex(r.float, g.float, b.float) };
                }
                log.panic("unknown color 'rgb(${r},${g},${b})'", .{});
            }
        }.func,
    },
    .{
        .name = "hsl",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *exp.CallExpr) Value {
                const h = context.evaluate(call.args.items[0]);
                const s = context.evaluate(call.args.items[1]);
                const l = context.evaluate(call.args.items[2]);
                if (@intFromEnum(h) == Tag.float and @intFromEnum(s) == Tag.float and @intFromEnum(l) == Tag.float and h.float >= 0 and s.float >= 0 and l.float >= 0) {
                    return .{ .float = hslToHex(h.float, s.float, l.float) };
                }
                log.panic("unknown color 'hsl(${h},${s},${l})'", .{});
            }
        }.func,
    },
};
