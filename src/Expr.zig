const std = @import("std");
const ExprEvaluator = @import("./ExprEvaluator.zig");
const OperatorDescriptor = @import("./ExprEvaluator.zig").OperatorDescriptor;
const ExprEvaluatorContext = @import("./ExprEvaluator.zig").ExprEvaluatorContext;
const console = @import("./console.zig");
const ExprParse = @import("./ExprParser.zig").ExprParser;
const ValueMap = @import("./Env.zig").ValueMap;
const MapEnv = @import("./Env.zig").MapEnv;
const alloc = @import("./alloc.zig");
const Tag = @import("./json.zig").Tag;
const interpolatedPropertyDefinitionToJsonExpr = @import("./InterpolatedPropertyDefs.zig").interpolatedPropertyDefinitionToJsonExpr;
const json = std.json;
const Value = json.Value;
const ObjectMap = json.ObjectMap;
const Array = json.Array;
pub fn ExprVisitor(comptime Result: type, comptime Context: type) type {
    return struct {
        pub const VTable = struct {
            visitNullLiteralExpr: *const fn (ctx: *anyopaque, expr: *NullLiteralExpr, context: Context) Result,
            visitBooleanLiteralExpr: *const fn (ctx: *anyopaque, expr: *BooleanLiteralExpr, context: Context) Result,
            visitNumberLiteralExpr: *const fn (ctx: *anyopaque, expr: *NumberLiteralExpr, context: Context) Result,
            visitStringLiteralExpr: *const fn (ctx: *anyopaque, expr: *StringLiteralExpr, context: Context) Result,
            visitObjectLiteralExpr: *const fn (ctx: *anyopaque, expr: *ObjectLiteralExpr, context: Context) Result,
            visitArrayLiteralExpr: *const fn (ctx: *anyopaque, expr: *ArrayLiteralExpr, context: Context) Result,
            visitVarExpr: *const fn (ctx: *anyopaque, expr: *VarExpr, context: Context) Result,
            visitHasAttributeExpr: *const fn (ctx: *anyopaque, expr: *HasAttributeExpr, context: Context) Result,
            visitCallExpr: *const fn (ctx: *anyopaque, expr: *CallExpr, context: Context) Result,
            visitLookupExpr: *const fn (ctx: *anyopaque, expr: *LookupExpr, context: Context) Result,
            visitMatchExpr: *const fn (ctx: *anyopaque, expr: *MatchExpr, context: Context) Result,
            visitCaseExpr: *const fn (ctx: *anyopaque, expr: *CaseExpr, context: Context) Result,
            visitStepExpr: *const fn (ctx: *anyopaque, expr: *StepExpr, context: Context) Result,
            visitInterpolateExpr: *const fn (ctx: *anyopaque, expr: *InterpolateExpr, context: Context) Result,
        };
        const Self = @This();
        ptr: *anyopaque,
        vtable: *const VTable,
        pub fn new(ptr: anytype) Self {
            const T = @TypeOf(ptr);
            const ptr_info = @typeInfo(T);
            const gen = struct {
                pub fn visitNullLiteralExpr(ctx: *anyopaque, expr: *NullLiteralExpr, context: Context) Result {
                    const self: T = @ptrCast(@alignCast(ctx));
                    return ptr_info.Pointer.child.visitNullLiteralExpr(self, expr, context);
                }
                pub fn visitBooleanLiteralExpr(ctx: *anyopaque, expr: *BooleanLiteralExpr, context: Context) Result {
                    const self: T = @ptrCast(@alignCast(ctx));
                    return ptr_info.Pointer.child.visitBooleanLiteralExpr(self, expr, context);
                }
                pub fn visitNumberLiteralExpr(ctx: *anyopaque, expr: *NumberLiteralExpr, context: Context) Result {
                    const self: T = @ptrCast(@alignCast(ctx));
                    return ptr_info.Pointer.child.visitNumberLiteralExpr(self, expr, context);
                }
                pub fn visitStringLiteralExpr(ctx: *anyopaque, expr: *StringLiteralExpr, context: Context) Result {
                    const self: T = @ptrCast(@alignCast(ctx));
                    return ptr_info.Pointer.child.visitStringLiteralExpr(self, expr, context);
                }
                pub fn visitObjectLiteralExpr(ctx: *anyopaque, expr: *ObjectLiteralExpr, context: Context) Result {
                    const self: T = @ptrCast(@alignCast(ctx));
                    return ptr_info.Pointer.child.visitObjectLiteralExpr(self, expr, context);
                }
                pub fn visitArrayLiteralExpr(ctx: *anyopaque, expr: *ArrayLiteralExpr, context: Context) Result {
                    const self: T = @ptrCast(@alignCast(ctx));
                    return ptr_info.Pointer.child.visitArrayLiteralExpr(self, expr, context);
                }
                pub fn visitVarExpr(ctx: *anyopaque, expr: *VarExpr, context: Context) Result {
                    const self: T = @ptrCast(@alignCast(ctx));
                    return ptr_info.Pointer.child.visitVarExpr(self, expr, context);
                }
                pub fn visitHasAttributeExpr(ctx: *anyopaque, expr: *HasAttributeExpr, context: Context) Result {
                    const self: T = @ptrCast(@alignCast(ctx));
                    return ptr_info.Pointer.child.visitHasAttributeExpr(self, expr, context);
                }
                pub fn visitCallExpr(ctx: *anyopaque, expr: *CallExpr, context: Context) Result {
                    const self: T = @ptrCast(@alignCast(ctx));
                    return ptr_info.Pointer.child.visitCallExpr(self, expr, context);
                }
                pub fn visitLookupExpr(ctx: *anyopaque, expr: *LookupExpr, context: Context) Result {
                    const self: T = @ptrCast(@alignCast(ctx));
                    return ptr_info.Pointer.child.visitLookupExpr(self, expr, context);
                }
                pub fn visitMatchExpr(ctx: *anyopaque, expr: *MatchExpr, context: Context) Result {
                    const self: T = @ptrCast(@alignCast(ctx));
                    return ptr_info.Pointer.child.visitMatchExpr(self, expr, context);
                }
                pub fn visitCaseExpr(ctx: *anyopaque, expr: *CaseExpr, context: Context) Result {
                    const self: T = @ptrCast(@alignCast(ctx));
                    return ptr_info.Pointer.child.visitCaseExpr(self, expr, context);
                }
                pub fn visitStepExpr(ctx: *anyopaque, expr: *StepExpr, context: Context) Result {
                    const self: T = @ptrCast(@alignCast(ctx));
                    return ptr_info.Pointer.child.visitStepExpr(self, expr, context);
                }
                pub fn visitInterpolateExpr(ctx: *anyopaque, expr: *InterpolateExpr, context: Context) Result {
                    const self: T = @ptrCast(@alignCast(ctx));
                    return ptr_info.Pointer.child.visitInterpolateExpr(self, expr, context);
                }
            };
            return .{ .ptr = ptr, .vtable = &.{
                .visitNullLiteralExpr = gen.visitNullLiteralExpr,
                .visitBooleanLiteralExpr = gen.visitBooleanLiteralExpr,
                .visitNumberLiteralExpr = gen.visitNumberLiteralExpr,
                .visitStringLiteralExpr = gen.visitStringLiteralExpr,
                .visitObjectLiteralExpr = gen.visitObjectLiteralExpr,
                .visitArrayLiteralExpr = gen.visitArrayLiteralExpr,
                .visitVarExpr = gen.visitVarExpr,
                .visitHasAttributeExpr = gen.visitHasAttributeExpr,
                .visitCallExpr = gen.visitCallExpr,
                .visitLookupExpr = gen.visitLookupExpr,
                .visitMatchExpr = gen.visitMatchExpr,
                .visitCaseExpr = gen.visitCaseExpr,
                .visitStepExpr = gen.visitStepExpr,
                .visitInterpolateExpr = gen.visitInterpolateExpr,
            } };
        }
        pub fn visitNullLiteralExpr(this: *Self, expr: *NullLiteralExpr, context: Context) Result {
            return this.vtable.visitNullLiteralExpr(this.ptr, expr, context);
        }
        pub fn visitBooleanLiteralExpr(this: *Self, expr: *BooleanLiteralExpr, context: Context) Result {
            return this.vtable.visitBooleanLiteralExpr(this.ptr, expr, context);
        }
        pub fn visitNumberLiteralExpr(this: *Self, expr: *NumberLiteralExpr, context: Context) Result {
            return this.vtable.visitNumberLiteralExpr(this.ptr, expr, context);
        }
        pub fn visitStringLiteralExpr(this: *Self, expr: *StringLiteralExpr, context: Context) Result {
            return this.vtable.visitStringLiteralExpr(this.ptr, expr, context);
        }
        pub fn visitObjectLiteralExpr(this: *Self, expr: *ObjectLiteralExpr, context: Context) Result {
            return this.vtable.visitObjectLiteralExpr(this.ptr, expr, context);
        }
        pub fn visitArrayLiteralExpr(this: *Self, expr: *ArrayLiteralExpr, context: Context) Result {
            return this.vtable.visitArrayLiteralExpr(this.ptr, expr, context);
        }
        pub fn visitVarExpr(this: *Self, expr: *VarExpr, context: Context) Result {
            return this.vtable.visitVarExpr(this.ptr, expr, context);
        }
        pub fn visitHasAttributeExpr(this: *Self, expr: *HasAttributeExpr, context: Context) Result {
            return this.vtable.visitHasAttributeExpr(this.ptr, expr, context);
        }
        pub fn visitCallExpr(this: *Self, expr: *CallExpr, context: Context) Result {
            return this.vtable.visitCallExpr(this.ptr, expr, context);
        }
        pub fn visitLookupExpr(this: *Self, expr: *LookupExpr, context: Context) Result {
            return this.vtable.visitLookupExpr(this.ptr, expr, context);
        }
        pub fn visitMatchExpr(this: *Self, expr: *MatchExpr, context: Context) Result {
            return this.vtable.visitMatchExpr(this.ptr, expr, context);
        }
        pub fn visitCaseExpr(this: *Self, expr: *CaseExpr, context: Context) Result {
            return this.vtable.visitCaseExpr(this.ptr, expr, context);
        }
        pub fn visitStepExpr(this: *Self, expr: *StepExpr, context: Context) Result {
            return this.vtable.visitStepExpr(this.ptr, expr, context);
        }
        pub fn visitInterpolateExpr(this: *Self, expr: *InterpolateExpr, context: Context) Result {
            return this.vtable.visitInterpolateExpr(this.ptr, expr, context);
        }
    };
}
pub const ExprScope = enum { Value, Condition, Dynamic };
pub const ExprTag = struct {
    pub const nullLiteral = 0;
    pub const booleanLiteral = 1;
    pub const numberLiteral = 2;
    pub const stringLiteral = 3;
    pub const objectLiteral = 4;
    pub const arrayLiteral = 5;
    pub const varExpr = 6;
    pub const hasAttributeExpr = 7;
    pub const callExpr = 8;
    pub const lookupExpr = 9;
    pub const matchExpr = 10;
    pub const caseExpr = 11;
    pub const stepExpr = 12;
    pub const interpolateExpr = 13;
};
pub const Expr = union(enum) {
    nullLiteral: *NullLiteralExpr,
    booleanLiteral: *BooleanLiteralExpr,
    numberLiteral: *NumberLiteralExpr,
    stringLiteral: *StringLiteralExpr,
    objectLiteral: *ObjectLiteralExpr,
    arrayLiteral: *ArrayLiteralExpr,
    varExpr: *VarExpr,
    hasAttributeExpr: *HasAttributeExpr,
    callExpr: *CallExpr,
    lookupExpr: *LookupExpr,
    matchExpr: *MatchExpr,
    caseExpr: *CaseExpr,
    stepExpr: *StepExpr,
    interpolateExpr: *InterpolateExpr,
    pub fn accept(self: Expr, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        switch (self) {
            .nullLiteral => return self.nullLiteral.accept(R, C, visitor, context),
            .booleanLiteral => return self.booleanLiteral.accept(R, C, visitor, context),
            .numberLiteral => return self.numberLiteral.accept(R, C, visitor, context),
            .stringLiteral => return self.stringLiteral.accept(R, C, visitor, context),
            .objectLiteral => return self.objectLiteral.accept(R, C, visitor, context),
            .arrayLiteral => return self.arrayLiteral.accept(R, C, visitor, context),
            .varExpr => return self.varExpr.accept(R, C, visitor, context),
            .hasAttributeExpr => return self.hasAttributeExpr.accept(R, C, visitor, context),
            .callExpr => return self.callExpr.accept(R, C, visitor, context),
            .lookupExpr => return self.lookupExpr.accept(R, C, visitor, context),
            .matchExpr => return self.matchExpr.accept(R, C, visitor, context),
            .caseExpr => return self.caseExpr.accept(R, C, visitor, context),
            .stepExpr => return self.stepExpr.accept(R, C, visitor, context),
            .interpolateExpr => return self.interpolateExpr.accept(R, C, visitor, context),
        }
    }
    pub fn exprIsDynamic(self: Expr) bool {
        switch (self) {
            .nullLiteral => return self.nullLiteral.exprIsDynamic(),
            .booleanLiteral => return self.booleanLiteral.exprIsDynamic(),
            .numberLiteral => return self.numberLiteral.exprIsDynamic(),
            .stringLiteral => return self.stringLiteral.exprIsDynamic(),
            .objectLiteral => return self.objectLiteral.exprIsDynamic(),
            .arrayLiteral => return self.arrayLiteral.exprIsDynamic(),
            .varExpr => return self.varExpr.exprIsDynamic(),
            .hasAttributeExpr => return self.hasAttributeExpr.exprIsDynamic(),
            .callExpr => return self.callExpr.exprIsDynamic(),
            .lookupExpr => return self.lookupExpr.exprIsDynamic(),
            .matchExpr => return self.matchExpr.exprIsDynamic(),
            .caseExpr => return self.caseExpr.exprIsDynamic(),
            .stepExpr => return self.stepExpr.exprIsDynamic(),
            .interpolateExpr => return self.interpolateExpr.exprIsDynamic(),
        }
    }
    // pub fn getValue(self: Expr) Value {
    //     switch (self) {
    //         .nullLiteral => return self.nullLiteral.getValue(),
    //         .booleanLiteral => return self.booleanLiteral.getValue(),
    //         .numberLiteral => return self.numberLiteral.getValue(),
    //         .stringLiteral => return self.stringLiteral.getValue(),
    //         .objectLiteral => return self.objectLiteral.getValue(),
    //         .arrayLiteral => return self.arrayLiteral.getValue(),
    //         .varExpr => return self.varExpr.getValue(),
    //         .hasAttributeExpr => unreachable,
    //         .callExpr => unreachable,
    //         .lookupExpr => unreachable,
    //         .matchExpr => unreachable,
    //         .caseExpr => unreachable,
    //         .stepExpr => unreachable,
    //         .interpolateExpr => return self.interpolateExpr.getValue(),
    //     }
    // }
    pub fn deinit(self: Expr) void {
        switch (self) {
            .nullLiteral => self.nullLiteral.deinit(),
            .booleanLiteral => self.booleanLiteral.deinit(),
            .numberLiteral => self.numberLiteral.deinit(),
            .stringLiteral => self.stringLiteral.deinit(),
            .objectLiteral => self.objectLiteral.deinit(),
            .arrayLiteral => self.arrayLiteral.deinit(),
            .varExpr => self.varExpr.deinit(),
            .hasAttributeExpr => self.hasAttributeExpr.deinit(),
            .callExpr => self.callExpr.deinit(),
            .lookupExpr => self.lookupExpr.deinit(),
            .matchExpr => self.matchExpr.deinit(),
            .caseExpr => self.caseExpr.deinit(),
            .stepExpr => self.stepExpr.deinit(),
            .interpolateExpr => self.interpolateExpr.deinit(),
        }
    }
    pub fn evaluate(self: Expr, env: MapEnv, scope: ?ExprScope, cache: ?*ExprEvaluatorContext.Cache) Value {
        return self.accept(Value, *ExprEvaluatorContext, ExprEvaluator.exprVisitor, ExprEvaluatorContext{
            .evaluator = ExprEvaluator.exprVisitor,
            .scope = if (scope) |s| s else ExprScope.Value,
            .cache = cache,
            .env = env,
        });
    }
    pub fn parse(text: []const u8) Expr {
        const parser = ExprParse.new(text);
        return parser.parse();
    }
    pub fn isDynamic(self: Expr) bool {
        return self.exprIsDynamic();
    }
    pub fn fromJson(jsonv: Value, definitions: ?Definitions, definitionExprCache: ?ReferenceResolverState.Cache) Expr {
        var referenceResolverState: ?*ReferenceResolverState = null;
        if (definitions) |d| {
            referenceResolverState = alloc.get().create(ReferenceResolverState) catch unreachable;
            referenceResolverState.?.* = ReferenceResolverState{
                .definitions = d,
                .lockedNames = ReferenceResolverState.LockedNames.init(alloc.get()),
                .cache = definitionExprCache orelse ReferenceResolverState.Cache.init(alloc.get()),
            };
        }
        const value = parseNode(jsonv, referenceResolverState);
        if (referenceResolverState) |ref| ref.deinit();
        return value;
    }
};
pub const VarExpr = struct {
    const Self = @This();
    name: []const u8,
    pub fn new(name: []const u8) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create VarExpr", .{});
        self.* = Self{ .name = name };
        return .{ .varExpr = self };
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitVarExpr(self, context);
    }
    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
    pub fn deinit(self: *Self) void {
        alloc.get().destroy(self);
    }
};
pub const BooleanLiteralExpr = struct {
    const Self = @This();
    value: bool,
    pub fn new(value: bool) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create BooleanLiteralExpr", .{});
        self.* = Self{ .value = value };
        return .{ .booleanLiteral = self };
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitBooleanLiteralExpr(self, context);
    }
    pub fn getValue(self: *Self) Value {
        return .{ .bool = self.value };
    }
    pub fn deinit(self: *Self) void {
        alloc.get().destroy(self);
    }
    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
};
pub const NumberLiteralExpr = struct {
    const Self = @This();
    value: f64,
    pub fn new(value: f64) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create NumberLiteralExpr", .{});
        self.* = Self{ .value = value };
        return .{ .numberLiteral = self };
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitNumberLiteralExpr(self, context);
    }
    pub fn getValue(self: *Self) Value {
        return .{ .float = self.value };
    }
    pub fn deinit(self: *Self) void {
        alloc.get().destroy(self);
    }
    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
};
pub const RGBA = struct {};
pub const Pixels = struct {};
pub const PromotedValue = union(enum) {
    rgba: RGBA,
    pixels: Pixels,
    null,
};
pub const StringLiteralExpr = struct {
    const Self = @This();
    value: []const u8,
    m_promotedValue: PromotedValue = PromotedValue.null,
    pub fn new(value: []const u8) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create StringLiteralExpr", .{});
        self.* = Self{ .value = value };
        return .{ .stringLiteral = self };
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitStringLiteralExpr(self, context);
    }
    pub fn getValue(self: *Self) Value {
        return .{ .string = self.value };
    }
    pub fn deinit(self: *Self) void {
        alloc.get().destroy(self);
    }
    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
};
pub const ObjectLiteralExpr = struct {
    const Self = @This();
    value: ObjectMap,
    pub fn new(value: ObjectMap) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create ObjectLiteralExpr", .{});
        self.* = Self{ .value = value };
        return .{ .objectLiteral = self };
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitObjectLiteralExpr(self, context);
    }
    pub fn getValue(self: *Self) Value {
        return .{ .object = self.value };
    }
    pub fn deinit(self: *Self) void {
        alloc.get().destroy(self);
    }
    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
};
pub const ArrayLiteralExpr = struct {
    const Self = @This();
    value: Array,
    pub fn new(value: Array) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create ArrayLiteralExpr", .{});
        self.* = Self{ .value = value };
        return .{ .arrayLiteral = self };
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitArrayLiteralExpr(self, context);
    }
    pub fn getValue(self: *Self) Value {
        return .{ .array = self.value };
    }
    pub fn deinit(self: *Self) void {
        alloc.get().destroy(self);
    }
    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
};
pub const NullLiteralExpr = struct {
    pub var instance: Expr = undefined;
    pub fn init() void {
        instance = NullLiteralExpr.new();
    }
    const Self = @This();
    pub fn new() Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create ArrayLiteralExpr", .{});
        self.* = Self{};
        return .{ .nullLiteral = self };
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitNullLiteralExpr(self, context);
    }
    pub fn getValue(_: *Self) Value {
        return .null;
    }
    pub fn deinit(self: *Self) void {
        alloc.get().destroy(self);
    }
    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
};
pub fn createLiteralExprFromValue(value: Value) Expr {
    switch (value) {
        .bool => |v| return BooleanLiteralExpr.new(v),
        .integer => |v| return NumberLiteralExpr.new(@floatFromInt(v)),
        .float => |v| return NumberLiteralExpr.new(v),
        .string => |v| return StringLiteralExpr.new(v),
        .object => |v| return ObjectLiteralExpr.new(v),
        else => console.panic("Not implemented", .{}),
    }
}

pub const HasAttributeExpr = struct {
    const Self = @This();
    name: []const u8,
    pub fn new(name: []const u8) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create HasAttributeExpr", .{});
        self.* = Self{ .name = name };
        return .{ .hasAttributeExpr = self };
    }
    pub fn getValue(_: *Self) Value {
        return .null;
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitHasAttributeExpr(self, context);
    }
    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
    pub fn deinit(self: *Self) void {
        alloc.get().destroy(self);
    }
};

pub const CallExpr = struct {
    const Self = @This();
    op: []const u8,
    args: std.ArrayList(Expr),
    descriptor: ?OperatorDescriptor = null,
    pub fn new(op: []const u8, args: std.ArrayList(Expr)) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create CallExpr", .{});
        self.* = Self{ .op = op, .args = args };
        return .{ .callExpr = self };
    }
    pub fn deinit(self: *Self) void {
        const a = alloc.get();
        a.free(self.args);
        a.destroy(self);
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitCallExpr(self, context);
    }
    pub fn exprIsDynamic(self: *Self) bool {
        const descriptor = self.descriptor orelse ExprEvaluator.exprEvaluator.getOperator(self.op);
        if (descriptor.isDynamicOperator) |isDynamicOperator| {
            if (isDynamicOperator(self)) {
                return true;
            }
        }
        for (self.args.items) |arg| {
            if (arg.isDynamic()) return true;
        }
        return false;
    }
};

pub const Definition = union(enum) {
    value: Value,
    interpolation: InterpolatedPropertyDefinition,
};
pub const Definitions = std.StringHashMap(DefinitionValue);
pub const DefinitionValue = union(enum) {
    verbose: VerboseDefinition,
    definition: Definition,
    const Self = @This();
    pub fn getValue(self: *const Self) Definition {
        switch (self.*) {
            .verbose => |d| return d.value,
            .definition => |d| return d,
        }
    }
};
const VerboseDefinitionType = enum { selector, boolean, number, string, color };
pub const VerboseDefinition = struct {
    ty: VerboseDefinitionType,
    value: Definition,
    description: []const u8,
};
pub const Interpolation = enum {
    Discrete,
    Linear,
    Cubic,
    Exponential,
};
pub const InterpolatedPropertyDefinition = struct {
    interpolation: Interpolation,
    zoomLevels: []f64,
    values: []Value,
    exponent: ?f64,
};
pub const ReferenceResolverState = struct {
    pub const Cache = std.StringHashMap(Expr);
    pub const LockedNames = std.StringHashMap([]const u8);
    definitions: Definitions,
    lockedNames: LockedNames,
    cache: Cache,
    const Self = @This();
    pub fn new() Self {
        return Self{
            .definitions = std.StringHashMap(DefinitionValue).init(alloc.get()),
            .lockedNames = std.StringHashMap([]const u8).init(alloc.get()),
            .cache = std.StringHashMap(Expr).init(alloc.get()),
        };
    }
    pub fn deinit(self: *Self) void {
        self.definitions.deinit();
        self.lockedNames.deinit();
        self.cache.deinit();
    }
};
pub const LookupExpr = struct {
    callExpr: CallExpr,
    const Self = @This();
    pub fn new(args: std.ArrayList(Expr)) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create LookupExpr", .{});
        self.* = Self{ .callExpr = CallExpr{ .op = "lookup", .args = args } };
        return .{ .lookupExpr = self };
    }
    pub fn deinit(self: *Self) void {
        self.callExpr.deinit(alloc.get());
        alloc.get().destroy(self);
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitLookupExpr(self, context);
    }
    pub fn parseArray(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {
        if (node.items.len == 0) {
            console.panic("missing lookup table in 'lookup' expression", .{});
        }
        const lookupTableNode = node.items[0];
        const lookupTableExpr = parseNode(lookupTableNode, referenceResolverState);
        if (@intFromEnum(lookupTableNode) != Tag.array) {
            console.panic("Invalid lookup table expression for operator 'lookup'. It must be a literal or a ref to one.\n", .{});
        }
        // const lookupTable = lookupTableExpr.objectLiteral.value;
        // if (@intFromEnum(lookupTable) != Tag.array) {
        //     console.panic("Invalid lookup table type ({}) for operator 'lookup'\n", .{@intFromEnum(lookupTable)});
        // }
        var args = std.ArrayList(Expr).init(alloc.get());
        args.append(lookupTableExpr) catch unreachable;
        for (node.items[2..]) |childExpr| {
            args.append(parseNode(childExpr, referenceResolverState)) catch unreachable;
        }
        return LookupExpr.new(args);
    }
    pub fn exprIsDynamic(self: *Self) bool {
        return self.callExpr.exprIsDynamic();
    }
};
pub const MatchExpr = struct {
    const Self = @This();
    value: Expr,
    branches: std.ArrayList(Condition),
    fallback: Expr,
    pub fn new(value: Expr, branches: std.ArrayList(Condition), fallback: Expr) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create LookupExpr", .{});
        self.* = Self{ .value = value, .branches = branches, .fallback = fallback };
        return .{ .matchExpr = self };
    }
    pub fn deinit(self: *Self) void {
        self.branches.deinit();
        alloc.get().destroy(self);
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitMatchExpr(self, context);
    }

    pub fn isValidMatchLabel(value: Value) bool {
        switch (value) {
            .string, .integer, .float, .object => return true,
            .array => |v| {
                if (v.items.len == 0) {
                    return false;
                }
                const firstEleType = @intFromEnum(v.items[0]);
                if (firstEleType == Tag.string or firstEleType == Tag.float or firstEleType == Tag.integer) {
                    for (v.items) |item| {
                        if (@intFromEnum(item) != firstEleType) {
                            return false;
                        }
                    }
                    return true;
                }
                return false;
            },
            else => return false,
        }
    }
    pub fn exprIsDynamic(self: *Self) bool {
        var hasDynamic = false;
        for (self.branches.items) |branch| {
            if (branch.expr.isDynamic()) {
                hasDynamic = true;
                break;
            }
        }
        return self.value.isDynamic() or hasDynamic or self.fallback.isDynamic();
    }
};
pub const CaseBranch = struct {
    expr1: Expr,
    expr2: Expr,
};
pub const CaseExpr = struct {
    const Self = @This();
    branches: std.ArrayList(CaseBranch),
    fallback: Expr,
    pub fn new(branches: std.ArrayList(CaseBranch), fallback: Expr) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create LookupExpr", .{});
        self.* = Self{ .branches = branches, .fallback = fallback };
        return .{ .caseExpr = self };
    }
    pub fn deinit(self: *Self) void {
        self.branches.deinit();
        alloc.get().destroy(self);
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitCaseExpr(self, context);
    }
    pub fn exprIsDynamic(self: *Self) bool {
        var hasDynamic = false;
        for (self.branches.items) |branch| {
            if (branch.expr1.isDynamic()) {
                hasDynamic = true;
                break;
            }
            if (branch.expr2.isDynamic()) {
                hasDynamic = true;
                break;
            }
        }
        return hasDynamic or self.fallback.isDynamic();
    }
};
pub const Stop = struct {
    index: usize,
    expr: Expr,
    pub fn new(index: usize, expr: Expr) Stop {
        return .{ .index = index, .expr = expr };
    }
};
pub const StepExpr = struct {
    const Self = @This();
    stops: std.ArrayList(Stop),
    input: Expr,
    defaultValue: Expr,
    pub fn new(input: Expr, stops: std.ArrayList(Stop), defaultValue: Expr) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create LookupExpr", .{});
        self.* = Self{ .input = input, .stops = stops, .defaultValue = defaultValue };
        return .{ .stepExpr = self };
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitStepExpr(self, context);
    }
    pub fn exprIsDynamic(self: *Self) bool {
        var hasDynamic = false;
        for (self.stops.items) |branch| {
            if (branch.expr.isDynamic()) {
                hasDynamic = true;
                break;
            }
        }
        return hasDynamic or self.input.isDynamic() or self.defaultValue.isDynamic();
    }
    pub fn deinit(self: *Self) void {
        alloc.get().destroy(self);
    }
};
pub const InterpolateMode = struct {
    const Self = @This();
    const InnterMode = enum { discrete, linear, cubic, exponential };
    mode: InnterMode,
    pub fn new(mode: InnterMode) Self {
        return Self{ .mode = mode };
    }
};
pub const InterpolateExpr = struct {
    const Self = @This();
    stops: std.ArrayList(Stop),
    input: Expr,
    mode: Value,
    pub fn new(mode: Value, input: Expr, stops: std.ArrayList(Stop)) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create LookupExpr", .{});
        self.* = Self{ .input = input, .stops = stops, .mode = mode };
        return .{ .interpolateExpr = self };
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitInterpolateExpr(self, context);
    }
    pub fn exprIsDynamic(self: *Self) bool {
        var hasDynamic = false;
        for (self.stops.items) |branch| {
            if (branch.expr.isDynamic()) {
                hasDynamic = true;
                break;
            }
        }
        return hasDynamic or self.input.isDynamic();
    }
    pub fn deinit(self: *Self) void {
        alloc.get().destroy(self);
    }
};

pub fn parseNode(node: Value, referenceResolverState: ?*ReferenceResolverState) Expr {
    switch (node) {
        .array => |value| return parseCall(value, referenceResolverState),
        .null => return NullLiteralExpr.instance,
        .bool => |value| return BooleanLiteralExpr.new(value),
        .float => |value| return NumberLiteralExpr.new(value),
        .integer => |value| return NumberLiteralExpr.new(@floatFromInt(value)),
        .string => |value| return StringLiteralExpr.new(value),
        else => |value| console.panic("failed to create expression from: {s}\n", .{@intFromEnum(value)}),
    }
}

pub fn parseCall(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {
    const op = node.items[0];
    if (@intFromEnum(op) != Tag.string) {
        console.panic("expected a builtin function name\n", .{});
    }
    const ops = op.string;
    if (std.mem.eql(u8, ops, "!has") or std.mem.eql(u8, ops, "!in")) {
        var list = std.ArrayList(Expr).initCapacity(alloc.get(), 1) catch unreachable;
        var params = json.Array.init(alloc.get());
        defer params.deinit();
        params.append(json.Value{ .string = ops[1..] }) catch unreachable;
        params.appendSlice(node.items[1..]) catch unreachable;
        list.items[0] = parseCall(params, referenceResolverState);
        return CallExpr.new("!", list);
    } else if (std.mem.eql(u8, ops, "ref")) {
        return resolveReference(node, referenceResolverState);
    } else if (std.mem.eql(u8, ops, "get")) {
        return parseGetExpr(node, referenceResolverState);
    } else if (std.mem.eql(u8, ops, "has")) {
        return parseHasExpr(node, referenceResolverState);
    } else if (std.mem.eql(u8, ops, "literal")) {
        return parseLiteralExpr(node);
    } else if (std.mem.eql(u8, ops, "match")) {
        return parseMatchExpr(node, referenceResolverState);
    } else if (std.mem.eql(u8, ops, "case")) {
        return parseCaseExpr(node, referenceResolverState);
    } else if (std.mem.eql(u8, ops, "interpolate")) {
        return parseInterpolateExpr(node, referenceResolverState);
    } else if (std.mem.eql(u8, ops, "step")) {
        return parseStepExpr(node, referenceResolverState);
    } else if (std.mem.eql(u8, ops, "lookup")) {
        return LookupExpr.parseArray(node, referenceResolverState);
    } else {
        return makeCallExpr(ops, node, referenceResolverState);
    }
}
fn resolveReference(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {
    if (@intFromEnum(node.items[1]) != Tag.string) {
        console.panic("expected the name of an attribute\n", .{});
    }
    if (referenceResolverState == null) {
        console.panic("ref used with no definitions\n", .{});
    }
    const name = node.items[1].string;
    if (referenceResolverState.?.lockedNames.contains(name)) {
        console.panic("circular referene to {s}\n", .{name});
    }
    if (!referenceResolverState.?.definitions.contains(name)) {
        console.panic("definition {s} not found for\n", .{name});
    }
    const cachedEntry = referenceResolverState.?.cache.get(name);
    if (cachedEntry) |entry| {
        return entry;
    }
    const definitionEntry = referenceResolverState.?.definitions.get(name) orelse unreachable;
    var result: Expr = undefined;
    const definitionValue = definitionEntry.getValue();
    if (@intFromEnum(definitionValue) == 1) {
        return Expr.fromJson(.{ .array = interpolatedPropertyDefinitionToJsonExpr(definitionValue.interpolation) }, null, null);
    } else {
        if (isJsonExpr(definitionValue.value)) {
            referenceResolverState.?.lockedNames.put(name, name) catch unreachable;
            //TODO 可能会失败
            result = parseNode(definitionValue.value, referenceResolverState);
        } else {
            return Expr.fromJson(definitionValue.value, null, null);
        }
    }
    referenceResolverState.?.cache.put(name, result) catch unreachable;
    return result;
}
fn parseGetExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {
    if (node.items.len >= 2) {
        return makeCallExpr("get", node, referenceResolverState);
    }
    const name = node.items[1];
    if (@intFromEnum(name) != Tag.string) {
        console.panic("expected the name of an attribute\n", .{});
    }
    return VarExpr.new(name.string);
}
fn parseHasExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {
    if (node.items.len >= 2) {
        return makeCallExpr("has", node, referenceResolverState);
    }
    const name = node.items[1];
    if (@intFromEnum(name) != Tag.string) {
        console.panic("expected the name of an attribute\n", .{});
    }
    return HasAttributeExpr.new(name.string);
}
fn parseLiteralExpr(node: Array) Expr {
    const obj = node.items[1];
    if (@intFromEnum(obj) != Tag.object) {
        console.panic("expected an object in 'literal' expression\n", .{});
    }
    return ObjectLiteralExpr.new(obj.object);
}
const Condition = struct {
    matchLabel: Value,
    expr: Expr,
};
fn parseMatchExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {
    if (node.items.len < 4) {
        console.panic("expected at least 3 arguments in 'match' expression\n", .{});
    }
    if (node.items.len % 2 == 0) {
        console.panic("fallback is missing in 'match' expression\n", .{});
    }
    const value = parseNode(node.items[1], referenceResolverState);

    var conditions = std.ArrayList(Condition).init(alloc.get());
    defer conditions.deinit();
    var i: usize = 2;
    while (i < node.items.len - 1) : (i += 2) {
        const label = node.items[i];
        if (!MatchExpr.isValidMatchLabel(label)) {
            console.panic("{any}  is not a valid label for 'match'\n", .{label});
        }
        const expr = parseNode(node.items[i + 1], referenceResolverState);
        conditions.append(.{ .matchLabel = label, .expr = expr }) catch unreachable;
    }
    const fallback = parseNode(node.items[node.items.len - 1], referenceResolverState);
    return MatchExpr.new(value, conditions, fallback);
}
fn parseCaseExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {
    if (node.items.len < 3) {
        console.panic("expected at least 3 arguments in 'case' expression\n", .{});
    }
    if (node.items.len % 2 == 0) {
        console.panic("fallback is missing in 'case' expression\n", .{});
    }
    var branches = std.ArrayList(CaseBranch).init(alloc.get());
    for (1..node.items.len - 1) |i| {
        const branch = node.items[i];
        const condition = parseNode(branch.array.items[0], referenceResolverState);
        const expr = parseNode(branch.array.items[1], referenceResolverState);
        branches.append(.{ .expr1 = condition, .expr2 = expr }) catch unreachable;
    }
    const caseFallback = parseNode(node.items[node.items.len - 1], referenceResolverState);
    return CaseExpr.new(branches, caseFallback);
}
fn isInterpolationMode(mode: Value) bool {
    if (@intFromEnum(mode) != Tag.array) {
        return false;
    }
    const firstEle = mode.array.items[0];
    if (@intFromEnum(firstEle) != Tag.string) {
        return false;
    }
    const it = firstEle.string;
    if (std.mem.eql(u8, it, "discrete") or std.mem.eql(u8, it, "linear") or std.mem.eql(u8, it, "cubic") or std.mem.eql(u8, it, "exponential")) {
        return true;
    }
    return false;
}
fn parseInterpolateExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {
    const mode = node.items[1];
    if (!isInterpolationMode(mode)) {
        console.panic("expected an interpolation type\n", .{});
    }
    const modeArray = mode.array;
    const it = modeArray.items[0].string;
    if (!std.mem.eql(u8, it, "exponential") and @intFromEnum(modeArray.items[1]) != Tag.float) {
        console.panic("expected an exponent for exponential interpolation\n", .{});
    }
    const input = parseNode(node.items[2], referenceResolverState);
    var stops = std.ArrayList(Stop).init(alloc.get());
    for (3..node.items.len) |i| {
        const stop = node.items[i];
        const key = stop.array.items[0];
        const value = stop.array.items[1];
        stops.append(.{ .index = @intCast(key.integer), .expr = parseNode(value, referenceResolverState) }) catch unreachable;
    }
    return InterpolateExpr.new(mode, input, stops);
}
fn parseStepExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {
    if (node.items.len < 2) {
        console.panic("expected the input of the 'step' operator\n", .{});
    }
    if (node.items.len < 3 or node.items.len % 2 != 0) {
        console.panic("not enough arguments\n", .{});
    }
    const input = parseNode(node.items[1], referenceResolverState);
    const defaultValue = parseNode(node.items[2], referenceResolverState);
    var stops = std.ArrayList(Stop).init(alloc.get());
    var i: usize = 3;
    while (i < node.items.len) : (i += 2) {
        const key = node.items[i];
        const value = parseNode(node.items[i + 1], referenceResolverState);
        stops.append(.{ .index = @intCast(key.integer), .expr = value }) catch unreachable;
    }
    return StepExpr.new(input, stops, defaultValue);
}
fn makeCallExpr(op: []const u8, node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {
    var args = std.ArrayList(Expr).init(alloc.get());
    for (node.items[1..]) |item| {
        args.append(parseNode(item, referenceResolverState)) catch unreachable;
    }
    return CallExpr.new(op, args);
}

fn isJsonExpr(node: Value) bool {
    if (@intFromEnum(node) == Tag.array) {
        if (node.array.items.len > 0 and @intFromEnum(node.array.items[0]) == Tag.string) {
            return true;
        }
    }
    return false;
}
const FakeExpr = union(enum) {
    string: []const u8,
    jsonValue: Value,
    expr: Expr,
};
fn evaluate(a: FakeExpr, env: MapEnv) Value {
    const expr = switch (a) {
        .string => |v| Expr.parse(v),
        .jsonValue => |v| Expr.fromJson(v, null, null),
        .expr => |v| v,
    };
    return expr.evaluate(env, null, null);
}
