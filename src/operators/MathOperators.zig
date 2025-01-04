const OperatorDescriptor = @import("../ExprEvaluator.zig").OperatorDescriptor;
const std = @import("std");
const Value = std.json.Value;
const ExprEvaluatorContext = @import("../ExprEvaluator.zig").ExprEvaluatorContext;
const exp = @import("../Expr.zig");
const Expr = exp.Expr;
const CallExpr = exp.CallExpr;
const log = @import("../console.zig");

pub const MathOperators = [_]OperatorDescriptor{
    .{
        .name = "^",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args[0]);
                const b = context.evaluate(call.args[1]);
                if (@TypeOf(a) != .float or @TypeOf(b) != .float) {
                    log.panic("invalid operands '{any}' and '{any}' for operator '^'\n", .{ a, b });
                }
                return .{ .float = std.math.pow(a, b) };
            }
        }.func,
    },
    .{
        .name = "-",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                if (call.args.items.len == 1) {
                    const value = context.evaluate(call.args.items[0]);
                    if (@TypeOf(value) != .float) {
                        log.panic("invalid operands '{any}' for operator '^'\n", .{value});
                    }
                    return .{ .float = -value.float };
                }
                const a = context.evaluate(call.args[0]);
                const b = context.evaluate(call.args[1]);
                if (@TypeOf(a) != .float or @TypeOf(b) != .float) {
                    log.panic("invalid operands '{any}' and '{any}' for operator '-'\n", .{ a, b });
                }
                return .{ .float = a.float - b.float };
            }
        }.func,
    },
    .{
        .name = "/",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args[0]);
                const b = context.evaluate(call.args[1]);
                if (@TypeOf(a) != .float or @TypeOf(b) != .float) {
                    log.panic("invalid operands '{any}' and '{any}' for operator '/'\n", .{ a, b });
                }
                return .{ .float = a.float / b.float };
            }
        }.func,
    },
    .{
        .name = "%",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args[0]);
                const b = context.evaluate(call.args[1]);
                if (@TypeOf(a) != .float or @TypeOf(b) != .float) {
                    log.panic("invalid operands '{any}' and '{any}' for operator '%'\n", .{ a, b });
                }
                return .{ .float = a.float % b.float };
            }
        }.func,
    },
    .{
        .name = "+",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                var sum: f64 = 0;
                for (call.args.items) |item| {
                    const value = context.evaluate(item);
                    if (@TypeOf(value) != .float) {
                        log.panic("invalid operands '{any}' for operator '+'\n", .{value});
                    }
                    sum += value.float;
                }
                return .{ .float = sum };
            }
        }.func,
    },
    .{
        .name = "*",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                var sum: f64 = 0;
                for (call.args.items) |item| {
                    const value = context.evaluate(item);
                    if (@TypeOf(value) != .float) {
                        log.panic("invalid operands '{any}' for operator '*'\n", .{value});
                    }
                    sum *= value.float;
                }
                return .{ .float = sum };
            }
        }.func,
    },
    .{
        .name = "abs",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args[0]);
                if (@TypeOf(a) != .float) {
                    log.panic("invalid operands '{any}' for operator 'abs'\n", .{a});
                }
                return .{ .float = std.math.abs(a.float) };
            }
        }.func,
    },
    .{
        .name = "acos",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args[0]);
                if (@TypeOf(a) != .float) {
                    log.panic("invalid operands '{any}' for operator 'acos'\n", .{a});
                }
                return .{ .float = std.math.acos(a.float) };
            }
        }.func,
    },
    .{
        .name = "asin",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args[0]);
                if (@TypeOf(a) != .float) {
                    log.panic("invalid operands '{any}' for operator 'asin'\n", .{a});
                }
                return .{ .float = std.math.asin(a.float) };
            }
        }.func,
    },
    .{
        .name = "atan",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args[0]);
                if (@TypeOf(a) != .float) {
                    log.panic("invalid operands '{any}' for operator 'atan'\n", .{a});
                }
                return .{ .float = std.math.atan(a.float) };
            }
        }.func,
    },
    .{
        .name = "ceil",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args[0]);
                if (@TypeOf(a) != .float) {
                    log.panic("invalid operands '{any}' for operator 'ceil'\n", .{a});
                }
                return .{ .float = std.math.ceil(a.float) };
            }
        }.func,
    },
    .{
        .name = "cos",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args[0]);
                if (@TypeOf(a) != .float) {
                    log.panic("invalid operands '{any}' for operator 'cos'\n", .{a});
                }
                return .{ .float = std.math.cos(a.float) };
            }
        }.func,
    },
    .{
        .name = "e",
        .call = struct {
            fn func(_: *ExprEvaluatorContext, _: *CallExpr) Value {
                return .{ .float = std.math.e };
            }
        }.func,
    },
    .{
        .name = "floor",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args[0]);
                if (@TypeOf(a) != .float) {
                    log.panic("invalid operands '{any}' for operator 'floor'\n", .{a});
                }
                return .{ .float = std.math.floor(a.float) };
            }
        }.func,
    },
    .{
        .name = "ln",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args[0]);
                if (@TypeOf(a) != .float) {
                    log.panic("invalid operands '{any}' for operator 'ln'\n", .{a});
                }
                return .{ .float = std.math.log(f64, std.math.e, a.float) };
            }
        }.func,
    },
    .{
        .name = "ln2",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args[0]);
                if (@TypeOf(a) != .float) {
                    log.panic("invalid operands '{any}' for operator 'ln2'\n", .{a});
                }
                return .{ .float = std.math.log(f64, 2, a.float) };
            }
        }.func,
    },
    .{
        .name = "log10",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args[0]);
                if (@TypeOf(a) != .float) {
                    log.panic("invalid operands '{any}' for operator 'log10'\n", .{a});
                }
                return .{ .float = std.math.log(f64, 10, a.float) };
            }
        }.func,
    },
    .{
        .name = "max",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                var max: f64 = 0;
                for (call.args.items) |item| {
                    const value = context.evaluate(item);
                    if (@TypeOf(value) != .float) {
                        log.panic("invalid operands '{any}' for operator 'max'\n", .{value});
                    }
                    if (max < value.float) {
                        max = value.float;
                    }
                }
                return .{ .float = max };
            }
        }.func,
    },
    .{
        .name = "min",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                var min: f64 = std.math.floatMax(f64);
                for (call.args.items) |item| {
                    const value = context.evaluate(item);
                    if (@TypeOf(value) != .float) {
                        log.panic("invalid operands '{any}' for operator 'min'\n", .{value});
                    }
                    if (min < value.float) {
                        min = value.float;
                    }
                }
                return .{ .float = min };
            }
        }.func,
    },
    .{
        .name = "clamp",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const v = context.evaluate(call.args[0]);
                const min = context.evaluate(call.args[1]);
                const max = context.evaluate(call.args[2]);
                if (@TypeOf(v) != .float or @TypeOf(min) != .float or @TypeOf(max) != .float) {
                    log.panic("invalid operands '{any}' and '{any}' and '{any}' for operator 'clamp'\n", .{ v, min, max });
                }
                return .{ .float = std.math.clamp(v, min, max) };
            }
        }.func,
    },
    .{
        .name = "pi",
        .call = struct {
            fn func(_: *ExprEvaluatorContext, _: *CallExpr) Value {
                return .{ .float = std.math.pi };
            }
        }.func,
    },
    .{
        .name = "round",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args[0]);
                if (@TypeOf(a) != .float) {
                    log.panic("invalid operands '{any}' for operator 'round'\n", .{a});
                }
                return .{ .float = std.math.round(a.float) };
            }
        }.func,
    },
    .{
        .name = "sin",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args[0]);
                if (@TypeOf(a) != .float) {
                    log.panic("invalid operands '{any}' for operator 'sin'\n", .{a});
                }
                return .{ .float = std.math.sin(a.float) };
            }
        }.func,
    },
    .{
        .name = "sqrt",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args[0]);
                if (@TypeOf(a) != .float) {
                    log.panic("invalid operands '{any}' for operator 'sqrt'\n", .{a});
                }
                return .{ .float = std.math.sqrt(a.float) };
            }
        }.func,
    },
    .{
        .name = "tan",
        .call = struct {
            fn func(context: *ExprEvaluatorContext, call: *CallExpr) Value {
                const a = context.evaluate(call.args[0]);
                if (@TypeOf(a) != .float) {
                    log.panic("invalid operands '{any}' for operator 'tan'\n", .{a});
                }
                return .{ .float = std.math.tan(a.float) };
            }
        }.func,
    },
};
