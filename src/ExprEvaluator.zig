
const ExprVisitor = @import("./ExprVisitor.zig");
const std = @import("std");
pub const OperatorDescriptor = struct{
    name:[]const u8,
    isDynamicOperator:?*const fn(call:CallExpr)bool = null,
    call:*const fn(context:ExprEvaluatorContext,call:CallExpr)Value,
    partialEvaluate:*const fn(context:ExprEvaluatorContext,call:CallExpr)Value = null,
}
pub const ExprEvaluatorContext = struct{
    
}

var operatorDescriptors:std.StringMap(OperatorDescriptor) = undefined;
pub fn init(alloc:std.mem.Allocator)Self{
    operatorDescriptors = std.StringMap(OperatorDescriptor).init(alloc) catch unreachable;
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
pub fn defineOperators()void{

}
fn visitNullLiteralExpr(expr: NullLiteralExpr, _: Context) void{

}
fn visitBooleanLiteralExpr:(expr: BooleanLiteralExpr, _: Context) void{
    return expr.value;
}
fn visitNumberLiteralExpr:(expr: NumberLiteralExpr, _: Context) void{
    return expr.value;
}
fn visitStringLiteralExpr:(expr: StringLiteralExpr, _: Context) void{
    return expr.value;
}
fn visitObjectLiteralExpr:(expr: ObjectLiteralExpr, _: Context) void{

}
fn visitVarExpr:(expr: VarExpr, context: Context) void{

}
fn visitHasAttributeExpr:(expr: HasAttributeExpr, context: Context) void{

}
fn visitCallExpr:(expr: CallExpr, context: Context) void{

}
fn visitLookupExpr:(expr: LookupExpr, context: Context) void{

}
fn visitMatchExpr:(expr: MatchExpr, context: Context) void{

}
fn visitCaseExpr:(expr: CaseExpr, context: Context) void{

}
fn visitStepExpr:(expr: StepExpr, context: Context) void{

}
fn visitInterpolateExpr:(expr: InterpolateExpr, context: Context) void{

}
pub fn exprVisitor()ExprVisitor{
    return .{
        .visitNullLiteralExpr = visitNullLiteralExpr,
        .visitBooleanLiteralExpr: = visitBooleanLiteralExpr,
        .visitNumberLiteralExpr: = visitNumberLiteralExpr,
        .visitStringLiteralExpr: = visitStringLiteralExpr,
        .visitObjectLiteralExpr: = visitObjectLiteralExpr,
        .visitVarExpr: = visitVarExpr,
        .visitHasAttributeExpr: = visitHasAttributeExpr,
        .visitCallExpr: = visitCallExpr,
        .visitLookupExpr: = visitLookupExpr,
        .visitMatchExpr: = visitMatchExpr,
        .visitCaseExpr: = visitCaseExpr,
        .visitStepExpr: = visitStepExpr,
        .visitInterpolateExpr: = visitInterpolateExpr,
    };
}