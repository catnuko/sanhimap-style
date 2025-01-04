const std = @import("std");
const ExprEvaluator = @import("./ExprEvaluator.zig");
const exprEvaluator = ExprEvaluator.exprVisitor();
const OperatorDescriptor = @import("./ExprEvaluator.zig").OperatorDescriptor;
const ExprEvaluatorContext = @import("./ExprEvaluator.zig").ExprEvaluatorContext;
const console = @import("./console.zig");
const ExprParse = @import("./ExprParser.zig").ExprParser;
const ValueMap = @import("./Env.zig").ValueMap;
const MapEnv = @import("./Env.zig").MapEnv;
const alloc = @import("./alloc.zig");
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
            return .{ .ptr = ptr, .vtable = &gen };
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
pub const Expr = struct {
    const Self = @This();
    pub const VTable = struct {
        accept: *const fn (ctx: *anyopaque, visitor: f64, context: f64) void,
        exprIsDynamic: *const fn (ctx: *anyopaque) bool,
        deinit: *const fn (ctx: *anyopaque) void,
    };
    ptr: *anyopaque,
    vtable: *const VTable,
    m_typeName: []const u8,
    m_isDynamic: ?bool = null,
    pub fn new(ptr: anytype) *Self {
        const T = @TypeOf(ptr);
        const ptr_info = @typeInfo(T);
        const gen = struct {
            pub fn accept(ctx: *anyopaque, visitor: f64, context: f64) void {
                const self: T = @ptrCast(@alignCast(ctx));
                return ptr_info.Pointer.child.accept(self, visitor, context);
            }
            pub fn exprIsDynamic(ctx: *anyopaque) bool {
                const self: T = @ptrCast(@alignCast(ctx));
                return ptr_info.Pointer.child.exprIsDynamic(self);
            }
            pub fn deinit(ctx: *anyopaque) void {
                const self: T = @ptrCast(@alignCast(ctx));
                return ptr_info.Pointer.child.deinit(self, alloc.get());
            }
            pub fn asVarExpr(ctx: *anyopaque) *VarExpr {
                const self: T = @ptrCast(@alignCast(ctx));
                return ptr_info.Pointer.child.deinit(self, alloc.get());
            }
        };
        const self = alloc.get().create(Self) catch unreachable;
        self.* = .{
            .ptr = ptr,
            .vtable = &.{
                .accept = gen.accept,
                .exprIsDynamic = gen.exprIsDynamic,
                .deinit = gen.deinit,
            },
            .m_typeName = @typeName(T),
        };
        return self;
    }
    pub fn parse(text: []const u8) *Expr {
        const parser = ExprParse.new(text);
        return parser.parse();
    }
    pub fn deinit(self: *Self) void {
        alloc.get().destroy(self.ptr);
        self.vtable.deinit(self.ptr, alloc.get());
    }
    pub fn evaluate(this: *Self, env: MapEnv, scope: *ExprScope, cache: ?ExprEvaluatorContext.Cache) Value {
        return this.accept(Value, ExprEvaluatorContext, exprEvaluator, ExprEvaluatorContext{
            .evaluator = exprEvaluator,
            .env = env,
            .scope = scope,
            .cache = cache,
        });
    }
    // pub fn instantiate(self: *Self, context: InstantiationContext) *Expr {}
    pub fn accept(this: *Self, comptime Result: type, comptime Context: type, visitor: *ExprVisitor(Result, Context), context: Context) Result {
        return this.vtable.accept(this.ptr, Result, Context, visitor, context);
    }
    pub fn isDynamic(self: Self) bool {
        if (self.m_isDynamic == null) {
            self.m_isDynamic = self.exprIsDynamic();
        }
        return self.m_isDynamic;
    }
    pub fn exprIsDynamic(this: *Self) bool {
        return this.vtable.exprIsDynamic(this.ptr);
    }
    pub fn getValue(this: *Self) Value {
        return this.vtable.getValue(this.ptr);
    }
    pub fn fromJson(jsonv: Value, definitions: ?Definitions, definitionExprCache: ?*std.StringHashMap(Expr)) *Expr {
        const referenceResolverState = if (definitions != null) ReferenceResolverState{
            .definitions = definitions.?,
            .lockedNames = std.StringHashMap(void).init(alloc.get()),
            .cache = definitionExprCache orelse std.StringHashMap(Expr).init(alloc.get()),
        } else null;
        defer referenceResolverState.?.deinit();
        return parseNode(jsonv, referenceResolverState);
    }
    pub fn asVarExpr(self: *Self) *VarExpr {
        return @ptrCast(@alignCast(self.ptr));
    }
    pub fn asBooleanLiteralExpr(self: *Self) *BooleanLiteralExpr {
        return @ptrCast(@alignCast(self.ptr));
    }
    pub fn asNumberLiteralExpr(self: *Self) *NumberLiteralExpr {
        return @ptrCast(@alignCast(self.ptr));
    }
    pub fn asStringLiteralExpr(self: *Self) *StringLiteralExpr {
        return @ptrCast(@alignCast(self.ptr));
    }
    pub fn asObjectLiteralExpr(self: *Self) *ObjectLiteralExpr {
        return @ptrCast(@alignCast(self.ptr));
    }
    pub fn asArrayLiteralExpr(self: *Self) *ArrayLiteralExpr {
        return @ptrCast(@alignCast(self.ptr));
    }
    pub fn asNullLiteralExpr(self: *Self) *NullLiteralExpr {
        return @ptrCast(@alignCast(self.ptr));
    }
    pub fn asHasAttributeExpr(self: *Self) *HasAttributeExpr {
        return @ptrCast(@alignCast(self.ptr));
    }
    pub fn asCallExpr(self: *Self) *CallExpr {
        return @ptrCast(@alignCast(self.ptr));
    }
    pub fn asLookupExpr(self: *Self) *LookupExpr {
        return @ptrCast(@alignCast(self.ptr));
    }
    pub fn asMatchExpr(self: *Self) *MatchExpr {
        return @ptrCast(@alignCast(self.ptr));
    }
    pub fn asCaseExpr(self: *Self) *CaseExpr {
        return @ptrCast(@alignCast(self.ptr));
    }
    pub fn asStepExpr(self: *Self) *StepExpr {
        return @ptrCast(@alignCast(self.ptr));
    }
    pub fn asInterpolateExpr(self: *Self) *InterpolateExpr {
        return @ptrCast(@alignCast(self.ptr));
    }
};
pub const VarExpr = struct {
    const Self = @This();
    name: []const u8,
    pub fn new(name: []const u8) *Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create VarExpr");
        self.* = Self{ .name = name };
        return Expr.new(self);
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitVarExpr(self, context);
    }
    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
    pub fn getValue(self: *Self) Value {
        return self.value;
    }
};
pub const BooleanLiteralExpr = struct {
    const Self = @This();
    value: bool,
    pub fn new(value: bool) *Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create BooleanLiteralExpr");
        self.* = Self{ .value = value };
        return Expr.new(self);
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitBooleanLiteralExpr(self, context);
    }
    pub fn getValue(self: *Self) Value {
        return .{ .bool = self.value };
    }
    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
};
pub const NumberLiteralExpr = struct {
    const Self = @This();
    value: f64,
    pub fn new(value: f64) *Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create NumberLiteralExpr");
        self.* = Self{ .value = value };
        return Expr.new(self);
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitNumberLiteralExpr(self, context);
    }
    pub fn getValue(self: *Self) Value {
        return .{ .float = self.value };
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
    pub fn new(value: []const u8) *Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create StringLiteralExpr");
        self.* = Self{ .value = value };
        return Expr.new(self);
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitStringLiteralExpr(self, context);
    }
    pub fn getValue(self: *Self) Value {
        return .{ .string = self.value };
    }
    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
};
pub const ObjectLiteralExpr = struct {
    const Self = @This();
    value: ObjectMap,
    pub fn new(value: ObjectMap) *Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create ObjectLiteralExpr");
        self.* = Self{ .value = value };
        return Expr.new(self);
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitObjectLiteralExpr(self, context);
    }
    pub fn getValue(self: *Self) Value {
        return .{ .object = self.value };
    }
    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
};
pub const ArrayLiteralExpr = struct {
    const Self = @This();
    value: Array,
    pub fn new(value: Array) *Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create ArrayLiteralExpr");
        self.* = Self{ .value = value };
        return Expr.new(self);
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitArrayLiteralExpr(self, context);
    }
    pub fn getValue(self: *Self) Value {
        return .{ .array = self.value };
    }
    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
};
pub const NullLiteralExpr = struct {
    pub var instance: *Expr = undefined;
    pub fn init() void {
        instance = NullLiteralExpr.new();
    }
    const Self = @This();
    pub fn new() *Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create ArrayLiteralExpr");
        self.* = Self{};
        return Expr.new(self);
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitNullLiteralExpr(self, context);
    }
    pub fn getValue(_: *Self) Value {
        return .null;
    }

    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
};
pub fn createLiteralExprFromValue(value: Value) *Expr {
    switch (@TypeOf(value)) {
        Value.bool => |v| return BooleanLiteralExpr.new(v),
        Value.interger => |v| return NumberLiteralExpr.new(@floatFromInt(v)),
        Value.float => |v| return NumberLiteralExpr.new(v),
        Value.string => |v| return StringLiteralExpr.new(v),
        Value.object => |v| return ObjectLiteralExpr.new(v),
        else => console.panic("Not implemented"),
    }
}

pub const HasAttributeExpr = struct {
    const Self = @This();
    name: []const u8,
    pub fn new(name: []const u8) *Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create HasAttributeExpr");
        self.* = Self{ .name = name };
        return Expr.new(self);
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitHasAttributeExpr(self, context);
    }
    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
};

pub const CallExpr = struct {
    const Self = @This();
    op: []const u8,
    args: std.ArrayList(*Expr),
    descriptor: ?OperatorDescriptor,
    pub fn new(op: []const u8, args: std.ArrayList(*Expr)) *Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create CallExpr");
        self.* = Self{ .op = op, .args = args };
        return Expr.new(self);
    }
    pub fn deinit(self: *Self) void {
        alloc.get().free(self.args);
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitCallExpr(self, context);
    }
    pub fn exprIsDynamic(self: *Self) bool {
        const descriptor = self.descriptor orelse ExprEvaluator.getOperator(self.op);
        if (descriptor) |desc| {
            if (desc.isDynamicOperator) |isDynamicOperator| {
                if (isDynamicOperator(self)) {
                    return true;
                }
            }
        }
        for (self.args) |arg| {
            if (arg.isDynamic()) return true;
        }
        return false;
    }
};

pub const Definition = union(enum) {
    value: Value,
    interpolation: InterpolatedPropertyDefinition,
};
pub const Definitions = std.StringHashMap(Definition);
pub const DefinitionValue = union(enum) {
    verbose: VerboseDefinition,
    definition: Definition,
    const Self = @This();
    pub fn getValue(self: *Self) Definition {
        switch (self.*) {
            .verbose => |d| return d.value,
            .definition => |d| return d,
        }
    }
};
const VerboseDefinitionType = enum { selector, boolean, number, string, color };
pub const VerboseDefinition = struct {
    ty: VerboseDefinitionType,
    value: DefinitionValue,
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
    definitions: Definitions,
    lockedNames: std.StringHashMap([]const u8),
    cache: std.StringHashMap(Expr),
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
    pub fn new(args: std.ArrayList(*Expr)) *Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create LookupExpr");
        self.* = Self{ .callExpr = CallExpr{ .op = "lookup", .args = args } };
        return Expr.new(self);
    }
    pub fn deinit(self: *Self) void {
        self.callExpr.deinit(alloc.get());
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitLookupExpr(self, context);
    }
    pub fn parseArray(node: Array, referenceResolverState: ?*ReferenceResolverState) *Expr {
        if (node.items.len == 0) {
            console.panic("missing lookup table in 'lookup' expression");
        }
        const lookupTableNode = node.items[0];
        const lookupTableExpr = parseNode(lookupTableNode, referenceResolverState);
        if (@TypeOf(lookupTableNode) != .array) {
            console.panic("Invalid lookup table expression for operator 'lookup'. It must be a literal or a ref to one.\n", .{});
        }
        const lookupTable = lookupTableExpr.getValue();
        if (@TypeOf(lookupTable) != Value.array) {
            console.panic("Invalid lookup table type ({}) for operator 'lookup'\n", .{@TypeOf(lookupTable)});
        }
        const args = std.ArrayList(*Expr).init(alloc.get());
        args.append(lookupTableExpr);
        for (node.items[2..]) |childExpr| {
            args.append(parseNode(childExpr, referenceResolverState)) catch unreachable;
        }
        return LookupExpr.new(args);
    }
};
pub const MatchExpr = struct {
    const Self = @This();
    value: *Expr,
    branches: std.ArrayList(Condition),
    fallback: *Expr,
    pub fn new(value: *Expr, branches: std.ArrayList(Condition), fallback: *Expr) *Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create LookupExpr");
        self.* = Self{ .value = value, .branches = branches, .fallback = fallback };
        return Expr.new(self);
    }
    pub fn deinit(self: *Self) void {
        self.branches.deinit();
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitMatchExpr(self, context);
    }

    pub fn isValidMatchLabel(value: Value) bool {
        switch (@TypeOf(value)) {
            .string, .interger, .float, .object => return true,
            .array => |v| {
                if (v.items.len == 0) {
                    return false;
                }
                const firstEleType = @TypeOf(v.items[0]);
                if (firstEleType == .string or firstEleType == .float or firstEleType == .interger) {
                    for (v.items) |item| {
                        if (@TypeOf(item) != firstEleType) {
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
    expr1: *Expr,
    expr2: *Expr,
};
pub const CaseExpr = struct {
    const Self = @This();
    branches: std.ArrayList(CaseBranch),
    fallback: *Expr,
    pub fn new(branches: std.ArrayList(CaseBranch), fallback: *Expr) *Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create LookupExpr");
        self.* = Self{ .branches = branches, .fallback = fallback };
        return Expr.new(self);
    }
    pub fn deinit(self: *Self) void {
        self.branches.deinit();
    }
    pub fn accept(self: *Self, comptime R: type, comptime C: type, visitor: *ExprVisitor(R, C), context: C) R {
        return visitor.visitCaseExpr(self, context);
    }
    pub fn exprIsDynamic(self: *Self) bool {
        var hasDynamic = false;
        for (self.branches.items) |branch| {
            if (branch.expr.isDynamic()) {
                hasDynamic = true;
                break;
            }
        }
        return hasDynamic or self.fallback.isDynamic();
    }
};
pub const Stop = struct {
    index: usize,
    expr: *Expr,
};
pub const StepExpr = struct {
    const Self = @This();
    stops: std.ArrayList(Stop),
    input: *Expr,
    defaultValue: *Expr,
    pub fn new(input: *Expr, stops: std.ArrayList(Stop), defaultValue: *Expr) *Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create LookupExpr");
        self.* = Self{ .input = input, .stops = stops, .defaultValue = defaultValue };
        return Expr.new(self);
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
    input: *Expr,
    mode: Value,
    pub fn new(mode: Value, input: *Expr, stops: std.ArrayList(Stop)) *Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create LookupExpr");
        self.* = Self{ .input = input, .stops = stops, .mode = mode };
        return Expr.new(self);
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
};

pub fn parseNode(node: Value, referenceResolverState: ?*ReferenceResolverState) *Expr {
    switch (node) {
        .array => |value| return parseCall(value, referenceResolverState),
        .null => return NullLiteralExpr.instance,
        .bool => |value| return BooleanLiteralExpr.new(value),
        .float => |value| return NumberLiteralExpr.new(value),
        .integer => |value| return NumberLiteralExpr.new(@floatFromInt(value)),
        .string => |value| return StringLiteralExpr.new(value),
        else => |value| console.panic("failed to create expression from: {s}\n", .{@typeName(@TypeOf(value))}),
    }
}

pub fn parseCall(node: Array, referenceResolverState: ?*ReferenceResolverState) *Expr {
    const op = node.items[0];
    if (@TypeOf(op) != Value.string) {
        console.panic("expected a builtin function name\n", .{});
    }
    const ops = op.string;
    if (std.mem.eql(u8, ops, "!has") or std.mem.eql(u8, ops, "!in")) {
        const list = alloc.get().alloc(Expr, 1);
        var params = json.Array.init(alloc.get());
        defer params.deinit();
        params.append(json.Value{ .string = ops[1..] }) catch unreachable;
        params.append(node.items[1..]) catch unreachable;
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
        return makeCallExpr(op, node, referenceResolverState);
    }
}
fn resolveReference(node: Array, referenceResolverState: ?*ReferenceResolverState) *Expr {
    if (@TypeOf(node.items[1]) != Value.string) {
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
        return entry.ptr;
    }
    var definitionEntry = referenceResolverState.?.definitions.get(name) orelse unreachable;
    var result: *Expr = undefined;
    const definitionValue = definitionEntry.getValue();
    if (definitionValue == .interpolation) {
        return Expr.fromJson(interpolatedPropertyDefinitionToJsonExpr(definitionEntry));
    } else if (isJsonExpr(node)) {
        definitionEntry = node;
    } else {
        return Expr.fromJson(definitionValue);
    }
    if (isJsonExpr(definitionEntry)) {
        referenceResolverState.?.lockedNames.put(name, name) catch unreachable;
        if (parseNode(definitionEntry, referenceResolverState)) |expr| {
            result = expr;
        } else {
            _ = referenceResolverState.?.lockedNames.remove(name);
        }
    } else {
        console.panic("unsupported definition {}\n", .{name});
    }
    referenceResolverState.?.cache.put(name, result) catch unreachable;
    return result;
}
fn parseGetExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) *Expr {
    if (node.items.len >= 2) {
        return makeCallExpr("get", node, referenceResolverState);
    }
    const name = node.items[1];
    if (@TypeOf(name) != Value.string) {
        console.panic("expected the name of an attribute\n", .{});
    }
    return VarExpr.new(name.string);
}
fn parseHasExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) *Expr {
    if (node.items.len >= 2) {
        return makeCallExpr("has", node, referenceResolverState);
    }
    const name = node.items[1];
    if (@TypeOf(name) != Value.string) {
        console.panic("expected the name of an attribute\n", .{});
    }
    return HasAttributeExpr.new(name.string);
}
fn parseLiteralExpr(node: Array) *Expr {
    const obj = node.items[1];
    if (@TypeOf(obj) != Value.object) {
        console.panic("expected an object in 'literal' expression\n", .{});
    }
    return ObjectLiteralExpr.new(obj.object);
}
const Condition = struct {
    matchLabel: Value,
    expr: *Expr,
};
fn parseMatchExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) *Expr {
    if (node.items.len < 4) {
        console.panic("expected at least 3 arguments in 'match' expression\n", .{});
    }
    if (node.items.len % 2 == 0) {
        console.panic("fallback is missing in 'match' expression\n", .{});
    }
    const value = parseNode(node.items[1], referenceResolverState);

    const conditions = std.ArrayList(Condition).init(alloc.get());
    defer conditions.deinit();
    var i = 2;
    while (i < node.items.len - 1) : (i += 2) {
        const label = node.items[i];
        if (!MatchExpr.isValidMatchLabel(label)) {
            console.panic("{any}  is not a valid label for 'match'\n", .{label});
        }
        const expr = parseNode(node.items[i + 1], referenceResolverState);
        conditions.append(.{ .matchLabel = label.string, .expr = expr }) catch unreachable;
    }
    const fallback = parseNode(node.items[node.items.len - 1], referenceResolverState);
    return MatchExpr.new(value, conditions, fallback);
}
fn parseCaseExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) *Expr {
    if (node.items.len < 3) {
        console.panic("expected at least 3 arguments in 'case' expression\n", .{});
    }
    if (node.items.len % 2 == 0) {
        console.panic("fallback is missing in 'case' expression\n", .{});
    }
    const branches = std.ArrayList(CaseBranch).init(alloc.get());
    for (1..node.items.len - 1) |i| {
        const branch = node.items[i];
        const condition = parseNode(branch.items[0], referenceResolverState);
        const expr = parseNode(branch.items[1], referenceResolverState);
        branches.append(.{ .expr1 = condition, .expr2 = expr }) catch unreachable;
    }
    const caseFallback = parseNode(node.items[node.items.len - 1], referenceResolverState);
    return CaseExpr.new(branches, caseFallback);
}
fn isInterpolationMode(mode: Value) bool {
    if (@TypeOf(mode) != .array) {
        return false;
    }
    const firstEle = mode.array.items[0];
    if (@TypeOf(firstEle) != .string) {
        return false;
    }
    const it = firstEle.string;
    if (std.mem.eql(u8, it, "discrete") or std.mem.eql(u8, it, "linear") or std.mem.eql(u8, it, "cubic") or std.mem.eql(u8, it, "exponential")) {
        return true;
    }
    return false;
}
fn parseInterpolateExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) *Expr {
    const mode = node.items[1];
    if (!isInterpolationMode(mode)) {
        console.panic("expected an interpolation type\n", .{});
    }
    const modeArray = mode.array;
    const it = modeArray.items[0].string;
    if (!std.mem.eql(u8, it, "exponential") and @TypeOf(modeArray.items[1]) != .float) {
        console.panic("expected an exponent for exponential interpolation\n", .{});
    }
    const input = parseNode(node.items[2], referenceResolverState);
    const stops = std.ArrayList(Stop).init(alloc.get());
    for (3..node.items.len) |i| {
        const stop = node.items[i];
        const key = stop.items[0];
        const value = stop.items[1];
        stops.append(.{ .key = key, .expr = parseNode(value, referenceResolverState) }) catch unreachable;
    }
    return InterpolateExpr.new(mode.string, input, stops);
}
fn parseStepExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) *Expr {
    if (node.items.len < 2) {
        console.panic("expected the input of the 'step' operator\n", .{});
    }
    if (node.items.len < 3 or node.items.len % 2 != 0) {
        console.panic("not enough arguments\n", .{});
    }
    const input = parseNode(node.items[1], referenceResolverState);
    const defaultValue = parseNode(node.items[2], referenceResolverState);
    const stops = std.ArrayList(Stop).init(alloc.get());
    var i = 3;
    while (i < node.items.len) : (i += 2) {
        const key = node.items[i];
        const value = parseNode(node.items[i + 1], referenceResolverState);
        stops.append(.{ .index = key, .expr = value }) catch unreachable;
    }
    return StepExpr.new(input, defaultValue, stops);
}
fn makeCallExpr(op: []const u8, node: Array, referenceResolverState: ?*ReferenceResolverState) *Expr {
    const args = std.ArrayList(Value).init(alloc.get());
    for (node.items[1..]) |item| {
        args.append(parseNode(item, referenceResolverState)) catch unreachable;
    }
    return CallExpr.new(op, args);
}

fn isJsonExpr(node: Value) bool {
    if (node == .array) |value| {
        if (value.items.len > 0 and value.items[0] == .string) {
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
test "Expr.basic" {
    const testing = std.testing;
    alloc.init(testing.allocator);
    const env = MapEnv.new(ValueMap.init(alloc.get()), null);
    testing.expect(evaluate("length('foo')", env) == 3);
}
