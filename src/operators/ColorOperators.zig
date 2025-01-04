const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const ColorUtils = @import("../ColorUtils.zig");
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;
const THREE = @import("../three.zig"); // 假设有一个对应的 Zig 文件
const log = @import("../console.zig");
fn rgbaToHex(r: f64, g: f64, b: f64, a: f64) f64 {
    return ColorUtils.getHexFromRgba(std.math.clamp(r, 0.0, 255.0) / 255.0, std.math.clamp(g, 0.0, 255.0) / 255.0, std.math.clamp(b, 0.0, 255.0) / 255.0, std.math.clamp(a, 0.0, 1.0));
}

fn rgbToHex(r: f64, g: f64, b: f64) f64 {
    return ColorUtils.getHexFromRgb(std.math.clamp(r, 0.0, 255.0) / 255.0, std.math.clamp(g, 0.0, 255.0) / 255.0, std.math.clamp(b, 0.0, 255.0) / 255.0);
}

fn hslToHex(h: f64, s: f64, l: f64) f64 {
    return ColorUtils.getHexFromHsl(std.math.euclideanModulo(h, 360.0) / 360.0, std.math.clamp(s, 0.0, 100.0) / 100.0, std.math.clamp(l, 0.0, 100.0) / 100.0);
}

pub const ColorOperators = [_]OperatorDescriptor{ .{
    .name = "alpha",
    .call = struct {
        fn func(context: *ExprEvaluatorContext, call: *Expr) Value {
            var color: Value = context.evaluate(call.args[0]);
            if (color.isString()) {
                color = parseStringEncodedColor(color);
            }
            const alpha = if (color.isNumber()) ColorUtils.getAlphaFromHex(color) else 1.0;
            return alpha;
        }
    }.func,
}, .{
    .name = "rgba",
    .call = struct {
        fn func(context: *ExprEvaluatorContext, call: *Expr) Value {
            const r = context.evaluate(call.args[0]);
            const g = context.evaluate(call.args[1]);
            const b = context.evaluate(call.args[2]);
            const a = context.evaluate(call.args[3]);
            if (@TypeOf(r) == .float and @TypeOf(g) == .float and @TypeOf(g) == .float and @TypeOf(b) == .float and
                r >= 0 and g >= 0 and b >= 0 and a >= 0 and a <= 1)
            {
                return rgbaToHex(r, g, b, a);
            }
            log.panic("unknown color 'rgba(${r},${g},${b},${a})'");
        }
    }.func,
}, .{
    .name = "rgb",
    .call = struct {
        fn func(context: *ExprEvaluatorContext, call: *Expr) Value {
            const r = context.evaluate(call.args[0]);
            const g = context.evaluate(call.args[1]);
            const b = context.evaluate(call.args[2]);
            if (@TypeOf(r) == .float and @TypeOf(g) == .float and @TypeOf(g) == .float and r >= 0 and g >= 0 and b >= 0) {
                return rgbToHex(r, g, b);
            }
            log.panic("unknown color 'rgb(${r},${g},${b})'");
        }
    }.func,
}, .{ .name = "hsl", .call = struct {
    fn func(context: *ExprEvaluatorContext, call: *Expr) Value {
        const h = context.evaluate(call.args[0]);
        const s = context.evaluate(call.args[1]);
        const l = context.evaluate(call.args[2]);
        if (@TypeOf(h) == .float and @TypeOf(s) == .float and @TypeOf(l) == .float and h >= 0 and s >= 0 and l >= 0) {
            return hslToHex(h, s, l);
        }
        log.panic("unknown color 'hsl(${h},${s},${l})'");
    }
} } };
