const std = @import("std");
const Expr = @import("./Expr.zig");
const alloc = @import("./alloc.zig");
const Env = @import("./Env.zig").MapEnv;
const Value = std.json.Value;
pub const OperatorDescriptor = struct {
    name: []const u8,
    isDynamicOperator: ?*const fn (call: Expr.CallExpr) bool = null,
    call: *const fn (context: ExprEvaluatorContext, call: Expr.CallExpr) Value,
    partialEvaluate: *const fn (context: ExprEvaluatorContext, call: Expr.CallExpr) Value = null,
};
pub const ExprEvaluatorContext = struct {
    evaluator: Expr.ExprVisitor,
    env: Env,
    scope: Expr.ExprScope,
    cache: std.AutoHashMap(Expr.Expr, Value),
    const Self = @This();
    pub fn evaluate(self:*Self,expr:Expr.Expr)Value{
        if(self.cache.get(expr))|cachedResult|{
            return cachedResult;
        }
        else{
            const result = expr.accept(self.evaluator,self);
            self.cache.put(expr, result);
            return result;
        }
    }
    pub fn wrapValue(self:*Self,value:Value)Expr{
        return Expr.createLiteralExprFromValue(value);
    }
};

var operatorDescriptors: std.StringMap(OperatorDescriptor) = undefined;
pub fn init() void {
    operatorDescriptors = std.StringMap(OperatorDescriptor).init(alloc.get()) catch unreachable;
    defineOperators(CastOperators);
    defineOperators(ComparisonOperators);
    defineOperators(MathOperators);
    defineOperators(StringOperators);
    defineOperators(ColorOperators);
    defineOperators(TypeOperators);
    defineOperators(MiscOperators);
    defineOperators(FlowOperators);
    defineOperators(ArrayOperators);
    defineOperators(ObjectOperators);
    defineOperators(FeatureOperators);
    defineOperators(MapOperators);
    defineOperators(VectorOperators);
}
pub fn defineOperators() void {}
pub fn getOperator(op: []const u8) void {}
fn visitNullLiteralExpr(_: Expr.NullLiteralExpr, _: ExprEvaluatorContext) Value {
    return .null;
}
fn visitBooleanLiteralExpr(expr: Expr.BooleanLiteralExpr, _: ExprEvaluatorContext) Value {
    return expr.value;
}
fn visitNumberLiteralExpr(expr: Expr.NumberLiteralExpr, _: ExprEvaluatorContext) Value {
    return expr.value;
}
fn visitStringLiteralExpr(expr: Expr.StringLiteralExpr, _: ExprEvaluatorContext) Value {
    return expr.value;
}
fn visitObjectLiteralExpr(expr: Expr.ObjectLiteralExpr, _: ExprEvaluatorContext) Value {
    return expr.value;
}
fn visitVarExpr(expr: Expr.VarExpr, context: ExprEvaluatorContext) Value {
    const value = context.env.lookup(expr.name);
    return value;
}
fn visitHasAttributeExpr(expr: Expr.HasAttributeExpr, context: ExprEvaluatorContext) Value {
    if (context.env.lookup(expr.name)) |_| {
        return .{ .bool = true };
    } else {
        return .{ .bool = false };
    }
}
fn visitCallExpr(expr: Expr.CallExpr, context: ExprEvaluatorContext) Value {

}
fn visitLookupExpr(expr: Expr.LookupExpr, context: ExprEvaluatorContext) Value {}
fn visitMatchExpr(expr: Expr.MatchExpr, context: ExprEvaluatorContext) Value {
    const r = context.
}
fn visitCaseExpr(expr: Expr.CaseExpr, context: ExprEvaluatorContext) Value {}
fn visitStepExpr(expr: Expr.StepExpr, context: ExprEvaluatorContext) Value {}
fn visitInterpolateExpr(expr: Expr.InterpolateExpr, context: ExprEvaluatorContext) Value {}
pub fn exprVisitor() Expr.ExprVisitor {
    return .{
        .visitNullLiteralExpr = visitNullLiteralExpr,
        .visitBooleanLiteralExpr = visitBooleanLiteralExpr,
        .visitNumberLiteralExpr = visitNumberLiteralExpr,
        .visitStringLiteralExpr = visitStringLiteralExpr,
        .visitObjectLiteralExpr = visitObjectLiteralExpr,
        .visitVarExpr = visitVarExpr,
        .visitHasAttributeExpr = visitHasAttributeExpr,
        .visitCallExpr = visitCallExpr,
        .visitLookupExpr = visitLookupExpr,
        .visitMatchExpr = visitMatchExpr,
        .visitCaseExpr = visitCaseExpr,
        .visitStepExpr = visitStepExpr,
        .visitInterpolateExpr = visitInterpolateExpr,
    };
}
