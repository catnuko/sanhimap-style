const exp = @import("./Expr.zig");
const std = @import("std");
const alloc = @import("./alloc.zig");
const Expr = exp.Expr;
pub const ExprPool = struct {
    const Self = @This();
    m_booleanLiterals: std.AutoHashMap(bool, *exp.BooleanLiteralExpr),
    m_numberLiterals: std.AutoHashMap(f64, *exp.NumberLiteralExpr),
    m_stringLiterals: std.StringHashMap(*exp.StringLiteralExpr),
    m_objectLiterals: std.AutoHashMap(*exp.ObjectLiteralExpr, *exp.ObjectLiteralExpr),
    m_arrayLiterals: std.ArrayList(*exp.ArrayLiteralExpr),
    m_varExprs: std.StringHashMap(*exp.VarExpr),
    m_hasAttributeExprs: std.StringHashMap(*exp.HasAttributeExpr),
    m_matchExprs: std.ArrayList(*exp.MatchExpr),
    m_caseExprs: std.ArrayList(*exp.CaseExpr),
    m_interpolateExprs: std.ArrayList(*exp.InterpolateExpr),
    m_stepExprs: std.ArrayList(*exp.StepExpr),
    m_callExprs: std.StringHashMap(std.ArrayList(*exp.CallExpr)),
    pub fn new() Self {
        const allocator = alloc.get();
        return Self{
            .m_booleanLiterals = std.AutoHashMap(bool, *exp.BooleanLiteralExpr).init(allocator),
            .m_numberLiterals = std.AutoHashMap(f64, *exp.NumberLiteralExpr).init(allocator),
            .m_stringLiterals = std.StringHashMap(*exp.StringLiteralExpr).init(allocator),
            .m_objectLiterals = std.AutoHashMap(*exp.ObjectLiteralExpr, *exp.ObjectLiteralExpr).init(allocator),
            .m_arrayLiterals = std.ArrayList(*exp.ObjectLiteralExpr).init(allocator),
            .m_varExprs = std.StringHashMap(*exp.VarExpr).init(allocator),
            .m_hasAttributeExprs = std.StringHashMap(*exp.HasAttributeExpr).init(allocator),
            .m_matchExprs = std.ArrayList(*exp.MatchExpr).init(allocator),
            .m_caseExprs = std.ArrayList(*exp.CaseExpr).init(allocator),
            .m_interpolateExprs = std.ArrayList(*exp.InterpolateExpr).init(allocator),
            .m_stepExprs = std.ArrayList(*exp.StepExpr).init(allocator),
            .m_callExprs = std.StringHashMap(*exp.CallExpr).init(allocator),
        };
    }
    pub fn deinit(self: *Self) void {
        self.m_booleanLiterals.deinit();
        self.m_numberLiterals.deinit();
        self.m_stringLiterals.deinit();
        self.m_objectLiterals.deinit();
        self.m_arrayLiterals.deinit();
        self.m_varExprs.deinit();
        self.m_hasAttributeExprs.deinit();
        self.m_matchExprs.deinit();
        self.m_caseExprs.deinit();
        self.m_interpolateExprs.deinit();
        self.m_stepExprs.deinit();
        self.m_callExprs.deinit();
    }
    pub fn exprVisitor(self: *Self) exp.ExprVisitor(Expr, void) {
        return exp.ExprVisitor(Expr, void).new(self);
    }
    pub fn add(self: *Self, expr: Expr) Expr {
        return expr.accept(Expr, void, self, null);
    }
    fn visitNullLiteralExpr(_: *Self, _: exp.NullLiteralExpr, _: void) Expr {
        return exp.NullLiteralexp.instance;
    }
    fn visitBooleanLiteralExpr(self: *Self, expr: *exp.BooleanLiteralExpr, _: void) Expr {
        const e = self.m_booleanLiterals.get(exp.value);
        if (e) |v| return v;
        self.m_booleanLiterals.put(exp.value, exp.value) catch unreachable;
        return expr;
    }
    fn visitNumberLiteralExpr(self: *Self, expr: *exp.NumberLiteralExpr, _: void) Expr {
        const e = self.m_numberLiterals.get(exp.value);
        if (e) |v| return v;
        self.m_numberLiterals.put(exp.value, exp.value) catch unreachable;
        return expr;
    }
    fn visitStringLiteralExpr(self: *Self, expr: *exp.StringLiteralExpr, _: void) Expr {
        const e = self.m_stringLiterals.get(exp.value);
        if (e) |v| return v;
        self.m_stringLiterals.put(exp.value, exp.value) catch unreachable;
        return expr;
    }
    fn visitObjectLiteralExpr(self: *Self, expr: *exp.ObjectLiteralExpr, _: void) Expr {
        const e = self.m_stringLiterals.get(exp.value);
        if (e) |v| return v;
        self.m_objectLiterals.put(exp.value, expr) catch unreachable;
        return expr;
    }
    fn visitArrayLiteralExpr(self: *Self, expr: *exp.ArrayLiteralExpr, _: void) Expr {
        const e = self.m_stringLiterals.get(exp.value);
        if (e) |v| return v;
        const array = exp.value;
        var r: exp.ArrayLiteralExpr = undefined;
        for (self.m_arrayLiterals.items) |literal| {
            const elements = literal.value.items;
            const a = array.items.len == elements.len;
            var every = true;
            for (array.items, 0..) |x, i| {
                if (x != elements.items[i]) {
                    every = false;
                    break;
                }
            }
            if (a and every) {
                r = literal;
                break;
            }
        }
        if (r != undefined) {
            return r;
        }
        self.m_arrayLiterals.append(expr) catch unreachable;
        return expr;
    }
    fn visitVarExpr(self: *Self, expr: *exp.VarExpr, _: void) Expr {
        const e = self.m_varExprs.get(exp.value);
        if (e) |v| return v;
        self.m_varExprs.put(exp.value, expr) catch unreachable;
        return expr;
    }
    fn visitHasAttributeExpr(self: *Self, expr: *exp.HasAttributeExpr, _: void) Expr {
        const e = self.m_hasAttributeExprs.get(exp.value);
        if (e) |v| return v;
        self.m_hasAttributeExprs.put(exp.value, expr) catch unreachable;
        return expr;
    }
    fn visitCallExprImpl(self: *Self, expr: *exp.CallExpr, _: void, isLookup: bool) Expr {
        const expressions = std.ArrayList(Expr).init(alloc.get());
        for (expr.branches.items) |item| {
            expressions.append(item.accept(Expr, void, self, null)) catch unreachable;
        }
        if (!self.m_callExprs.contains(expr.op)) {
            self.m_callExprs.put(expr.op, std.ArrayList(*exp.CallExpr).init(alloc.get())) catch unreachable;
        }
        const calls = self.m_callExprs.get(expr.op) orelse unreachable;
        for (calls) |call| {
            if (call.args.items.len != expressions.items.len) {
                continue;
            }
            var index = 0;
            for (0..call.args.items.len) |i| {
                if (call.args.items[i] != expressions.items[i]) {
                    index = i;
                    break;
                }
            }
            if (index == call.args.items.len) {
                return call;
            }
        }
        if (isLookup) {
            var e = exp.LookupExpr.new(expr.op, expressions);
            e.descriptor = expr.descriptor;
            calls.append(e) catch unreachable;
            return e;
        } else {
            var e = exp.CallExpr.new(expr.op, expressions);
            e.descriptor = expr.descriptor;
            calls.append(e) catch unreachable;
            return e;
        }
    }
    fn visitCallExpr(self: *Self, expr: *exp.CallExpr, _: void) Expr {
        return self.visitCallExprImpl(expr, null, false);
    }
    fn visitLookupExpr(self: *Self, expr: *exp.LookupExpr, _: void) Expr {
        return self.visitCallExprImpl(expr, null, true);
    }
    fn visitMatchExpr(self: *Self, expr: *exp.MatchExpr, _: void) Expr {
        const value = expr.value.accept(Expr, void, self, null);
        const branches = std.ArrayList(struct {
            label: std.json.Value,
            expr: Expr,
        }).init(alloc.get());
        for (expr.branches.items) |item| {
            branches.append(.{
                .label = item.matchLabel,
                .expr = item.expr.accept(Expr, void, self, null),
            }) catch unreachable;
        }
        const fallback = expr.fallback.accept(Expr, void, self, null);
        for (self.m_matchExprs.items) |candidate| {
            if (candidate.value != value) {
                continue;
            }
            if (candidate.fallback != fallback) {
                continue;
            }
            if (candidate.branches.items.len != branches.items.len) {
                continue;
            }
            var branchesMatching = true;
            for (0..branches.items.len) |i| {
                if (branches.items[i].label != candidate.branches.items[i].matchLabel or
                    branches.items[i].expr != candidate.branches.items[i].expr)
                {
                    branchesMatching = false;
                    break;
                }
            }
            if (branchesMatching) {
                return candidate;
            }
        }
        const r = exp.MatchExpr.new(value, branches, fallback);
        self.m_matchExprs.append(r) catch unreachable;
        return r;
    }
    fn visitCaseExpr(self: *Self, expr: *exp.CaseExpr, _: void) Expr {
        const value = expr.value.accept(Expr, void, self, null);
        const branches = std.ArrayList(exp.CaseBranch).init(alloc.get());
        for (expr.branches.items) |item| {
            branches.append(.{
                .expr1 = item.expr1.accept(Expr, void, self, null),
                .expr2 = item.expr2.accept(Expr, void, self, null),
            }) catch unreachable;
        }
        const fallback = expr.fallback.accept(Expr, void, self, null);
        for (self.m_caseExprs.items) |candidate| {
            if (candidate.fallback != fallback) {
                continue;
            }
            if (candidate.branches.items.len != branches.items.len) {
                continue;
            }
            var branchesMatching = true;
            for (0..branches.items.len) |i| {
                if (branches.items[i].label != candidate.branches.items[i].matchLabel or
                    branches.items[i].expr != candidate.branches.items[i].expr)
                {
                    branchesMatching = false;
                    break;
                }
            }
            if (branchesMatching) {
                return candidate;
            }
        }
        const r = exp.CaseExpr.new(value, branches, fallback);
        self.m_caseExprs.append(r) catch unreachable;
        return r;
    }
    fn visitStepExpr(self: *Self, expr: *exp.StepExpr, _: void) Expr {
        for (self.m_stepExprs.items) |step| {
            if (step == expr) {
                return step;
            }
        }
        const input = expr.input.accept(Expr, void, self, null);
        const defaultValue = expr.defaultValue.accept(Expr, void, self, null);
        var stops = std.ArrayList(exp.Stop).init(alloc.get());
        for (expr.stops.items) |stop| {
            const key = stop.key;
            const value = stop.expr.accept(Expr, void, self, null);
            stops.append(if (value == stop.expr) stop else exp.Stop{ .expr = value, .index = key }) catch unreachable;
        }
        for (self.m_stepExprs.items) |step| {
            if (step.input == input and step.defaultValue == defaultValue and step.stops.items.len == stops.items.len) {
                var matching = true;
                for (0..stops.items.len) |i| {
                    if (stops.items[i].expr != step.stops.items[i].expr or stops.items[i].index != step.stops.items[i].index) {
                        matching = false;
                        break;
                    }
                }
                if (matching) {
                    return step;
                }
            }
        }
        const e = exp.StepExpr.new(input, defaultValue, stops);
        self.m_stepExprs.append(e) catch unreachable;
        return e;
    }
    fn visitInterpolateExpr(self: *Self, expr: *exp.InterpolateExpr, _: void) Expr {
        for (self.m_interpolateExprs.items) |step| {
            if (step == expr) {
                return step;
            }
        }
        const input = expr.input.accept(Expr, void, self, null);
        var stops = std.ArrayList(exp.Stop).init(alloc.get());
        for (expr.stops.items) |stop| {
            const key = stop.key;
            const value = stop.expr.accept(Expr, void, self, null);
            stops.append(if (value == stop.expr) stop else exp.Stop{ .expr = value, .index = key }) catch unreachable;
        }
        for (self.m_interpolateExprs.items) |step| {
            if (step.input == input and step.mode == expr.mode and step.stops.items.len == stops.items.len) {
                var matching = true;
                for (0..stops.items.len) |i| {
                    if (stops.items[i].expr != step.stops.items[i].expr or stops.items[i].index != step.stops.items[i].index) {
                        matching = false;
                        break;
                    }
                }
                if (matching) {
                    return step;
                }
            }
        }
        const e = exp.StepExpr.new(expr.mode, input, stops);
        self.m_interpolateExprs.append(e) catch unreachable;
        return e;
    }
};
