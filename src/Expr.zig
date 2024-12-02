const std = @import("std");
const ExprEvaluator = @import("./ExprEvaluator.zig");
const exprEvaluator = ExprEvaluator.exprVisitor();
const OperatorDescriptor = @import("./ExprEvaluator.zig").OperatorDescriptor;
const ExprEvaluatorContext = @import("./ExprEvaluator.zig").ExprEvaluatorContext;
const console = @import("./console.zig");
const MapEnv = @import("./Env.zig").MapEnv;
const alloc = @import("./alloc.zig");
const json = std.json;
const Value = json.Value;
const ObjectMap = json.ObjectMap;
const Array = json.Array;
pub const Context = struct {};
pub const ExprVisitor = struct {
    visitNullLiteralExpr: *const fn (expr: NullLiteralExpr, context: Context) Value,
    visitBooleanLiteralExpr: *const fn (expr: BooleanLiteralExpr, context: Context) Value,
    visitNumberLiteralExpr: *const fn (expr: NumberLiteralExpr, context: Context) Value,
    visitStringLiteralExpr: *const fn (expr: StringLiteralExpr, context: Context) Value,
    visitObjectLiteralExpr: *const fn (expr: ObjectLiteralExpr, context: Context) Value,
    visitArrayLiteralExpr: *const fn (expr: ArrayLiteralExpr, context: Context) Value,
    visitVarExpr: *const fn (expr: VarExpr, context: Context) Value,
    visitHasAttributeExpr: *const fn (expr: HasAttributeExpr, context: Context) Value,
    visitCallExpr: *const fn (expr: CallExpr, context: Context) Value,
    visitLookupExpr: *const fn (expr: LookupExpr, context: Context) Value,
    visitMatchExpr: *const fn (expr: MatchExpr, context: Context) Value,
    visitCaseExpr: *const fn (expr: CaseExpr, context: Context) Value,
    visitStepExpr: *const fn (expr: StepExpr, context: Context) Value,
    visitInterpolateExpr: *const fn (expr: InterpolateExpr, context: Context) Value,
};
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
    pub fn new(ptr: anytype) Self {
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
        };
        return .{
            .ptr = ptr,
            .vtable = &.{
                .accept = gen.accept,
            },
        };
    }
    pub fn deinit(self: *Self) void {
        alloc.get().destroy(self.ptr);
        self.vtable.deinit(self.ptr, alloc.get());
    }
    pub fn evaluate(this: *Self, env: MapEnv, scope: ExprScope, cache: ?Cache) Value {
        return this.accept(exprEvaluator, ExprEvaluatorContext{
            .evaluator = exprEvaluator,
            .env = env,
            .scope = scope,
            .cache = cache,
        });
    }
    pub fn accept(this: *Self, visitor: ExprVisitor, context: Context) void {
        return this.vtable.accept(this.ptr, visitor, context);
    }
    pub fn exprIsDynamic(this: *Self) bool {
        return this.vtable.exprIsDynamic(this.ptr);
    }
    pub fn getValue(this: *Self) Value {
        return this.vtable.getValue(this.ptr);
    }
    pub fn fromJson(json: Value, definitions: ?Definitions, definitionExprCache: ?*std.StringHashMap(Expr)) Expr {
        const referenceResolverState = if (definitions != null) .{
            .definitions = definitions.?,
            .lockedNames = std.StringHashMap(void).init(alloc.get()),
            .cache = definitionExprCache orelse std.StringHashMap(Expr).init(alloc.get()),
        } else null;
        return parseNode(json, referenceResolverState);
    }
};

pub const VarExpr = struct {
    const Self = @This();
    name: []const u8,
    pub fn new(name: []const u8) Expr {
        return .{ .name = name };
    }
    pub fn accept(self: *Self, visitor: ExprVisitor, context: Context) Value {
        return visitor.visitVarExpr(self, context);
    }
    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
    pub fn getValue(self: *Self) Value {
        return self.value;
    }
    pub fn expr(self: *Self) Expr {
        return Expr.new(self);
    }
};
pub const BooleanLiteralExpr = struct {
    const Self = @This();
    value: bool,
    pub fn new(value: bool) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create BooleanLiteralExpr");
        self.* = Self{ .value = value };
        return Expr.new(self);
    }
    pub fn accept(self: *Self, visitor: ExprVisitor, context: Context) Value {
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
    pub fn new(value: f64) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create NumberLiteralExpr");
        self.* = Self{ .value = value };
        return Expr.new(self);
    }
    pub fn accept(self: *Self, visitor: ExprVisitor, context: Context) Value {
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
    pub fn new(value: []const u8) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create StringLiteralExpr");
        self.* = Self{ .value = value };
        return Expr.new(self);
    }
    pub fn accept(self: *Self, visitor: ExprVisitor, context: Context) Value {
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
    pub fn new(value: ObjectMap) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create ObjectLiteralExpr");
        self.* = Self{ .value = value };
        return Expr.new(self);
    }
    pub fn accept(self: *Self, visitor: ExprVisitor, context: Context) Value {
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
    pub fn new(value: Array) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create ArrayLiteralExpr");
        self.* = Self{ .value = value };
        return Expr.new(self);
    }
    pub fn accept(self: *Self, visitor: ExprVisitor, context: Context) Value {
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
    var instance: Expr = undefined;
    pub fn init() void {
        instance = NullLiteralExpr.new();
    }
    const Self = @This();
    pub fn new() Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create ArrayLiteralExpr");
        self.* = Self{};
        return Expr.new(self);
    }
    pub fn accept(self: *Self, visitor: ExprVisitor, context: Context) Value {
        return visitor.visitNullLiteralExpr(self, context);
    }
    pub fn getValue(_: *Self) Value {
        return .null;
    }
    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
};
pub fn createLiteralExprFromValue(value: Value) Expr {
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
    pub fn new(name: []const u8) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create HasAttributeExpr");
        self.* = Self{ .name = name };
        return Expr.new(self);
    }
    pub fn accept(self: *Self, visitor: ExprVisitor, context: Context) Value {
        return visitor.visitHasAttributeExpr(self, context);
    }
    pub fn exprIsDynamic(_: *Self) bool {
        return false;
    }
};

pub const CallExpr = struct {
    const Self = @This();
    op: []const u8,
    args: []Expr,
    descriptor: ?OperatorDescriptor,
    pub fn new(op: []const u8, args: []Expr) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create CallExpr");
        self.* = Self{ .op = op, .args = args };
        return Expr.new(self);
    }
    pub fn deinit(self: *Self) void {
        alloc.get().free(self.args);
    }
    pub fn accept(self: *Self, visitor: ExprVisitor, context: Context) Value {
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
    definitions: std.StringHashMap(DefinitionValue),
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
};
pub const LookupExpr = struct {
    callExpr: CallExpr,
    const Self = @This();
    pub fn new(args: []Expr) Expr {
        const self = alloc.get().create(Self) catch console.panic("Failed to create LookupExpr");
        self.* = Self{ .callExpr = CallExpr{ .op = "lookup", .args = args } };
        return Expr.new(self);
    }
    pub fn deinit(self: *Self) void {
        self.callExpr.deinit(alloc.get());
    }
    pub fn accept(self: *Self, visitor: ExprVisitor, context: Context) Value {
        return visitor.visitLookupExpr(self, context);
    }
    pub fn parseArray(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {
        if (node.items.len == 0) {
            console.panic("missing lookup table in 'lookup' expression");
        }
        const lookupTableNode = node.items[0];
        const lookupTableExpr = parseNode(lookupTableNode, referenceResolverState);
    }
};
pub const MatchExpr = struct {
    pub fn isValidMatchLabel(value: Value) bool {}
};
pub fn parseNode(node: Value, referenceResolverState: ?*ReferenceResolverState) Expr {
    switch (node) {
        .array => |value| return parseCall(value, referenceResolverState),
        .null => return NullLiteralExpr.instance,
        .bool => |value| return BooleanLiteralExpr.new(value),
        .float => |value| return NumberLiteralExpr.new(value),
        .integer => |value| return NumberLiteralExpr.new(@floatFromInt(value)),
        .string => |value| return StringLiteralExpr.new(value),
        else => |value| console.panic("failed to create expression from: {s}", .{@typeName(@TypeOf(value))}),
    }
}

pub fn parseCall(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {
    const op = node.items[0];
    if (@TypeOf(op) != Value.string) {
        console.panic("expected a builtin function name", .{});
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
fn resolveReference(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {
    if (@TypeOf(node.items[1]) != Value.string) {
        console.panic("expected the name of an attribute", .{});
    }
    if (referenceResolverState == null) {
        console.panic("ref used with no definitions", .{});
    }
    const name = node.items[1].string;
    if (referenceResolverState.?.lockedNames.contains(name)) {
        console.panic("circular referene to {s}", .{name});
    }
    if (!referenceResolverState.?.definitions.contains(name)) {
        console.panic("definition {s} not found for", .{name});
    }
    const cachedEntry = referenceResolverState.?.cache.get(name);
    if (cachedEntry) |entry| {
        return entry.ptr;
    }
    var definitionEntry = referenceResolverState.?.definitions.get(name) orelse unreachable;
    var result: Expr = undefined;
    const definitionValue = definitionEntry.getValue();
    if (definitionValue == .interpolation) {
        return Expr.fromJson(interpolatedPropertyDefinitionToJsonExpr(definitionEntry));
    } else if (isJsonExpr(node)) {
        definitionEntry = node;
    } else {
        return Expr.fromJson(definitionValue);
    }
    if (isJsonExpr(definitionEntry)) {
        referenceResolverState.?.lockedNames.put(name, name) catch unreachablea;
        if (parseNode(definitionEntry, referenceResolverState)) |expr| {
            result = expr;
        } else {
            _ = referenceResolverState.?.lockedNames.remove(name);
        }
    } else {
        console.panic("unsupported definition {}\n", .{name});
    }
    referenceResolverState.?.cache.put(name, result) catch unreachablea;
    return result;
}
fn parseGetExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {
    if (node.items.len >= 2) {
        return makeCallExpr("get", node, referenceResolverState);
    }
    const name = node.items[1];
    if (@TypeOf(name) != Value.string) {
        console.panic("expected the name of an attribute", .{});
    }
    return VarExpr.new(name.string);
}
fn parseHasExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {
    if (node.items.len >= 2) {
        return makeCallExpr("has", node, referenceResolverState);
    }
    const name = node.items[1];
    if (@TypeOf(name) != Value.string) {
        console.panic("expected the name of an attribute", .{});
    }
    return HasAttributeExpr.new(name.string);
}
fn parseLiteralExpr(node: Array) Expr {
    const obj = node.items[1];
    if (@TypeOf(obj) != Value.object) {
        console.panic("expected an object in 'literal' expression", .{});
    }
    return ObjectLiteralExpr.new(obj.object);
}
fn parseMatchExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {
    if (node.items.len < 4) {
        console.panic("expected at least 3 arguments in 'match' expression", .{});
    }
    if (node.items.len % 2 == 0) {
        console.panic("fallback is missing in 'match' expression", .{});
    }
    const value = parseNode(node.items[1], referenceResolverState);
    const Condition = struct {
        matchLabel: MatchLabel,
        expr: Expr,
    };
    const conditions = std.ArrayList(Condition).init(alloc.get()) catch unreachable;
    defer conditions.deinit();
    var i = 2;
    while (i < node.items.len - 1) : (i += 2) {
        const label = node.items[i];
        if (!MatchExpr.isValidMatchLabel(label)) {
            console.panic("{any}  is not a valid label for 'match'", .{label});
        }
        const expr = parseNode(node.items[i + 1], referenceResolverState);
        conditions.append(.{ .matchLabel = label.string, .expr = expr }) catch unreachable;
    }
}
fn parseCaseExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {}
fn parseInterpolateExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {}
fn parseStepExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {}
fn makeCallExpr(node: Array, referenceResolverState: ?*ReferenceResolverState) Expr {}

fn isJsonExpr(node: Value) bool {
    if (node == .array) |value| {
        if (value.items.len > 0 and value.items[0] == .string) {
            return true;
        }
    }
    return false;
}
