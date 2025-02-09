const std = @import("std");
const exp = @import("./Expr.zig");
const Expr = exp.Expr;
const alloc = @import("./alloc.zig");
const Env = @import("./Env.zig").MapEnv;
const Value = std.json.Value;
const Tag = @import("./json.zig").Tag;
const eql = @import("./json.zig").eql;
const console = @import("./console.zig");
const operators = @import("./operators/index.zig");
pub const OperatorDescriptor = struct {
    name: []const u8,
    isDynamicOperator: ?*const fn (call: *exp.CallExpr) bool = null,
    call: *const fn (context: *ExprEvaluatorContext, call: *exp.CallExpr) Value,
    partialEvaluate: ?*const fn (context: *ExprEvaluatorContext, call: *exp.CallExpr) Value = null,
};
const InnerExprVisitor = exp.ExprVisitor(Value, *ExprEvaluatorContext);
pub const ExprEvaluatorContext = struct {
    pub const Cache = std.AutoHashMap(Expr, Value);
    evaluator: *InnerExprVisitor,
    env: Env,
    scope: exp.ExprScope,
    cache: ?*Cache,
    const Self = @This();
    pub fn evaluate(self: *Self, expr: Expr) Value {
        if (self.cache) |cache| {
            const cachedResult = cache.get(expr);
            if (cachedResult) |result| {
                return result;
            }
        }
        const result = expr.accept(Value, *Self, self.evaluator, self);
        if (self.cache) |cache| {
            cache.put(expr, result) catch unreachable;
        }
        return result;
    }
    pub fn wrapValue(_: *Self, value: Value) Expr {
        return exp.createLiteralExprFromValue(value);
    }
};

pub const ExprEvaluator = struct {
    const Self = @This();
    operatorDescriptors: std.StringArrayHashMap(OperatorDescriptor),
    pub fn new() *Self {
        const self = alloc.get().create(Self) catch unreachable;
        self.* = Self{ .operatorDescriptors = std.StringArrayHashMap(OperatorDescriptor).init(alloc.get()) };
        self.defineOperators(&operators.CastOperators);
        self.defineOperators(&operators.ComparisonOperators);
        self.defineOperators(&operators.MathOperators);
        self.defineOperators(&operators.StringOperators);
        self.defineOperators(&operators.ColorOperators);
        self.defineOperators(&operators.TypeOperators);
        self.defineOperators(&operators.MiscOperators);
        self.defineOperators(&operators.FlowOperators);
        self.defineOperators(&operators.ArrayOperators);
        self.defineOperators(&operators.ObjectOperators);
        self.defineOperators(&operators.FeatureOperators);
        self.defineOperators(&operators.MapOperators);
        self.defineOperators(&operators.VectorOperators);
        return self;
    }
    pub fn deinit(self: *Self) void {
        self.operatorDescriptors.deinit();
        alloc.get().free(self);
    }
    pub fn exprVisitor(self: *Self) exp.ExprVisitor(Value, ExprEvaluatorContext) {
        return exp.ExprVisitor(Value, ExprEvaluatorContext).new(self);
    }
    pub fn defineOperators(self: *Self, operatorsv: []const OperatorDescriptor) void {
        for (operatorsv) |op| {
            self.operatorDescriptors.put(op.name, op) catch unreachable;
        }
    }
    pub fn getOperator(self: *Self, op: []const u8) OperatorDescriptor {
        return self.operatorDescriptors.get(op) orelse unreachable;
    }
    pub fn visitNullLiteralExpr(_: *Self, _: *exp.NullLiteralExpr, _: *ExprEvaluatorContext) Value {
        return .null;
    }
    pub fn visitBooleanLiteralExpr(_: *Self, expr: *exp.BooleanLiteralExpr, _: *ExprEvaluatorContext) Value {
        return expr.getValue();
    }
    pub fn visitNumberLiteralExpr(_: *Self, expr: *exp.NumberLiteralExpr, _: *ExprEvaluatorContext) Value {
        return expr.getValue();
    }
    pub fn visitStringLiteralExpr(_: *Self, expr: *exp.StringLiteralExpr, _: *ExprEvaluatorContext) Value {
        return expr.getValue();
    }
    pub fn visitArrayLiteralExpr(_: *Self, expr: *exp.ArrayLiteralExpr, _: *ExprEvaluatorContext) Value {
        return expr.getValue();
    }
    pub fn visitObjectLiteralExpr(_: *Self, expr: *exp.ObjectLiteralExpr, _: *ExprEvaluatorContext) Value {
        return expr.getValue();
    }
    pub fn visitVarExpr(_: *Self, expr: *exp.VarExpr, context: *ExprEvaluatorContext) Value {
        const value = context.env.lookup(expr.name) orelse return .null;
        return value;
    }
    pub fn visitHasAttributeExpr(_: *Self, expr: *exp.HasAttributeExpr, context: *ExprEvaluatorContext) Value {
        if (context.env.lookup(expr.name)) |_| {
            return .{ .bool = true };
        } else {
            return .{ .bool = false };
        }
    }
    pub fn visitCallExpr(_: *Self, expr: *exp.CallExpr, context: *ExprEvaluatorContext) Value {
        const descOpt = expr.descriptor orelse operatorDescriptors.get(expr.op);
        if (descOpt) |desc| {
            expr.descriptor = desc;

            var result: Value = undefined;
            if (context.scope == exp.ExprScope.Value and expr.exprIsDynamic()) {
                if (expr.descriptor.?.partialEvaluate) |p| {
                    return p(context, expr);
                }
                var args = std.ArrayList(Value).init(alloc.get());
                for (expr.args.items) |arg| {
                    const vv = context.evaluate(arg);
                    args.append(context.wrapValue(vv)) catch unreachable;
                }
                result = exp.CallExpr.new(expr.op, args);
            } else {
                result = desc.?.call(context, expr);
            }
            return result;
        }
        console.panic("undefined operator '{}'\n", .{expr.op});
    }
    pub fn visitLookupExpr(self: *Self, expr: *exp.LookupExpr, context: *ExprEvaluatorContext) Value {
        return self.visitCallExpr(&expr.callExpr, context);
    }
    pub fn visitMatchExpr(_: *Self, match: *exp.MatchExpr, context: *ExprEvaluatorContext) Value {
        const r = context.evaluate(match.value);
        for (match.branches.items) |branch| {
            const label = branch.matchLabel;
            const body = branch.expr;
            if (@intFromEnum(label) == Tag.array) {
                var include = false;
                for (label.array.items) |l| {
                    if (std.mem.eql(u8, l.string, r.string)) {
                        include = true;
                        break;
                    }
                }
                if (include) {
                    return context.evaluate(body);
                } else if (eql(&label, &r)) {
                    return context.evaluate(body);
                }
            } else if (eql(&label, &r)) {
                return context.evaluate(body);
            }
        }
        return context.evaluate(match.fallback);
    }
    pub fn visitCaseExpr(_: *Self, match: *exp.CaseExpr, context: *ExprEvaluatorContext) Value {
        if (context.scope == exp.ExprScope.Value) {
            const firstDynamicCondition = blk: {
                for (match.branches.items, 0..) |branch, i| {
                    if (branch.expr1.isDynamic()) {
                        break :blk @as(i32, @intCast(i));
                    }
                    if (branch.expr2.isDynamic()) {
                        break :blk @as(i32, @intCast(i));
                    }
                }
                break :blk -1;
            };
            if (firstDynamicCondition != -1) {
                var branches: std.ArrayList(exp.CaseBranch) = undefined;
                for (match.branches.items, 0..) |branch, i| {
                    const condition = branch.expr1;
                    const body = branch.expr2;

                    const evaluatedCondition = context.evaluate(condition);
                    const evaluatedBody = context.evaluate(body);

                    const typeeee = @intFromEnum(evaluatedCondition);
                    const isExpr = Expr.isExpr(evaluatedCondition);
                    if (i < firstDynamicCondition and typeeee == Tag.bool) {
                        return evaluatedBody;
                    }

                    if (!isExpr and typeeee != Tag.bool) {
                        continue;
                    }

                    if (branches == undefined) {
                        branches = std.ArrayList(exp.CaseBranch).init(alloc.get());
                    }

                    branches.append(exp.CaseBranch.new(context.wrapValue(evaluatedCondition), context.wrapValue(evaluatedBody))) catch unreachable;

                    if (!isExpr and typeeee == Tag.bool) {
                        return exp.CaseExpr.new(branches, exp.createLiteralExprFromValue(.null));
                    }
                }
                const fallback = context.evaluate(match.fallback);

                return if (branches == undefined) fallback else exp.CaseExpr.new(branches, context.wrapValue(fallback));
            }
        }
        for (match.branches.items) |branch| {
            if (context.evaluate(branch.expr1)) {
                return context.evaluate(branch.expr2);
            }
        }
        return context.evaluate(match.fallback);
    }
    pub fn visitStepExpr(_: *Self, expr: *exp.StepExpr, context: *ExprEvaluatorContext) Value {
        if (context.scope == exp.ExprScope.Value) {
            const input = context.evaluate(expr.input);
            const defaultValue = context.evaluate(expr.defaultValue);
            var stops = std.ArrayList(exp.Stop).init(alloc.get());
            for (expr.stops.items) |stop| {
                stops.append(exp.Stop.new(stop.index, context.wrapValue(context.evaluate(stop.expr)))) catch unreachable;
            }
            return exp.StepExpr.new(context.wrapValue(input), stops, context.wrapValue(defaultValue));
        } else {
            const input = context.evaluate(expr.input);

            if (@intFromEnum(input) != Tag.float) {
                console.panic("input '{}' must be a number\n", .{input});
            }

            if (input < expr.stops[0][0]) {
                return context.evaluate(expr.defaultValue);
            }

            var index = blk: {
                for (expr.stops, 0..) |stop, i| {
                    if (stop.index > input) {
                        break :blk i;
                    }
                }
                break :blk -1;
            };
            if (index == -1) {
                index = expr.stops.len;
            }
            return context.evaluate(expr.stops[index - 1][1]);
        }
    }
    pub fn visitInterpolateExpr(_: *Self, expr: *exp.InterpolateExpr, context: *ExprEvaluatorContext) Value {
        if (context.scope == exp.ExprScope.Value) {
            const input = context.evaluate(expr.input);

            var stops = std.ArrayList(exp.Stop).init(alloc.get());
            for (expr.stops.items) |stop| {
                stops.append(exp.Stop.new(stop.index, context.wrapValue(context.evaluate(stop.expr)))) catch unreachable;
            }
            return exp.InterpolateExpr.new(expr.mode, context.wrapValue(input), stops);
        } else {
            const param = context.evaluate(expr.input);

            if (@intFromEnum(param) != Tag.float) {
                console.panic("input must be a number\n", .{});
            }

            if (std.mem.eql(u8, expr.mode.array.items[0].string, "cubic")) {
                return cubicInterpolate(context, expr, param);
            }

            const keyIndex = blk: {
                for (expr.stops.items, 0..) |stop, i| {
                    if (stop.index > param) {
                        break :blk i;
                    }
                }
                break :blk -1;
            };
            if (keyIndex == -1) {
                return context.evaluate(expr.stops.items[expr.stops.items.len - 1].expr);
            } else if (keyIndex == 0) {
                return context.evaluate(expr.stops.items[0].expr);
            }

            const stop = expr.stops.items[keyIndex];
            const key = stop.index;
            // const value = stop.expr;

            const stop2 = expr.stops.items[keyIndex - 1];
            const prevKey = stop2.index;
            const prevValue = stop2.expr;

            const v0 = promoteValue(context, prevValue);
            var t = 0;

            const v = expr.mode.array.items[0].string;
            if (std.mem.eql(u8, v, "discrete")) {
                return v0;
            } else if (std.mem.eql(u8, v, "linear")) {
                t = (param - key) / (key - prevKey);
            } else if (std.mem.eql(u8, v, "exponential")) {
                const base = expr.mode.array.items[1].float;
                t = if (base == 1) (param - prevKey) / (key - prevKey) else (std.math.pow(base, param - prevKey) - 1) /
                    (std.math.pow(base, key - prevKey) - 1);
            } else {
                console.panic("interpolation mode {any} is not supported\n", .{expr.mode});
            }
            const v1 = promoteValue(context, prevValue);

            if (@intFromEnum(v0) == Tag.float and @intFromEnum(v1) == Tag.float) {
                return std.math.lerp(v0, v1, t);
            }
            console.panic("todo: mix({any},{any})\n", .{ v0, v1 });
        }
    }
};

pub var exprEvaluator: *ExprEvaluator = undefined;
pub var exprVisitor: *InnerExprVisitor = undefined;
pub fn init() void {
    exprEvaluator = ExprEvaluator.new();
    exprVisitor = alloc.get().create(InnerExprVisitor) catch unreachable;
    exprVisitor.* = InnerExprVisitor.new(exprEvaluator);
}
pub fn deinit() void {
    exprEvaluator.deinit();
    alloc.get().destroy(exprVisitor);
}
var operatorDescriptors: std.StringHashMap(OperatorDescriptor) = undefined;

fn cubicInterpolate(context: *ExprEvaluatorContext, interp: *exp.InterpolateExpr, t: f64) Value {
    if (t < interp.stops.items[0].index) {
        return promoteValue(context, interp.stops.items[0].expr);
    } else {
        return promoteValue(context, interp.stops.items[interp.stops.items.len - 1].expr);
    }

    const ii1 = blk: {
        for (interp.stops.items, 0..) |stop, i| {
            if (stop.index > t) {
                break :blk i;
            }
        }
        break :blk -1;
    };
    const ii0 = @max(0, ii1 - 1);
    const iP = if (ii0 == 0) ii1 else ii0 - 1;
    const iN = if (ii1 < interp.stops.length - 1) ii1 + 1 else ii1 - 1;

    // keys
    const tP = interp.stops[iP][0];
    const t0 = interp.stops[ii0][0];
    const t1 = interp.stops[ii1][0];
    const tN = interp.stops[iN][0];

    const dt = (t1 - t0) * 0.5;
    const wP = dt / (t0 - tP);
    const wN = dt / (tN - t1);
    const p = (t - t0) / (t1 - t0);
    const pp = p * p;
    const ppp = pp * p;

    // coefficients
    const cP = -wP * ppp + 2 * wP * pp - wP * p;
    const c0 = (1 + wP) * ppp + (-1.5 - 2 * wP) * pp + (-0.5 + wP) * p + 1;
    const c1 = (-1 - wN) * ppp + (1.5 + wN) * pp + 0.5 * p;
    const cN = wN * ppp - wN * pp;

    const vP = promoteValue(context, interp.stops.items[iP].expr);
    const v0 = promoteValue(context, interp.stops.items[ii0].expr);
    const v1 = promoteValue(context, interp.stops.items[ii1].expr);
    const vN = promoteValue(context, interp.stops.items[iN].expr);

    if (@intFromEnum(vP) == Tag.float and @intFromEnum(v0) == Tag.float and @intFromEnum(v1) == Tag.float and @intFromEnum(vN) == Tag.float) {
        return cP * vP + c0 * v0 + c1 * v1 + cN * vN;
    }
    console.panic("failed to interpolate values\n", .{});
}

fn promoteValue(context: *ExprEvaluatorContext, expr: Expr) Value {
    if (std.mem.eql(u8, @tagName(expr), "stringLiteral")) {
        return if (expr.asStringLiteralExpr().m_promotedValue) |v| v else expr.getValue();
    }
    const value = context.evaluate(expr);

    if (@intFromEnum(value) == Tag.string) {
        //TODO RGBA.parse
        return value;
    }
    return value;
}
