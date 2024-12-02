// pub const ExprVisitor = struct {
//     const Self = @This();
//     pub const VTable = struct {
//         visitNullLiteralExpr: *const fn (ctx: *anyopaque, expr: NullLiteralExpr, context: Context) void,
//         visitBooleanLiteralExpr: *const fn (ctx: *anyopaque, expr: BooleanLiteralExpr, context: Context) void,
//         visitNumberLiteralExpr: *const fn (ctx: *anyopaque, expr: NumberLiteralExpr, context: Context) void,
//         visitStringLiteralExpr: *const fn (ctx: *anyopaque, expr: StringLiteralExpr, context: Context) void,
//         visitObjectLiteralExpr: *const fn (ctx: *anyopaque, expr: ObjectLiteralExpr, context: Context) void,
//         visitVarExpr: *const fn (ctx: *anyopaque, expr: VarExpr, context: Context) void,
//         visitHasAttributeExpr: *const fn (ctx: *anyopaque, expr: HasAttributeExpr, context: Context) void,
//         visitCallExpr: *const fn (ctx: *anyopaque, expr: CallExpr, context: Context) void,
//         visitLookupExpr: *const fn (ctx: *anyopaque, expr: LookupExpr, context: Context) void,
//         visitMatchExpr: *const fn (ctx: *anyopaque, expr: MatchExpr, context: Context) void,
//         visitCaseExpr: *const fn (ctx: *anyopaque, expr: CaseExpr, context: Context) void,
//         visitStepExpr: *const fn (ctx: *anyopaque, expr: StepExpr, context: Context) void,
//         visitInterpolateExpr: *const fn (ctx: *anyopaque, expr: InterpolateExpr, context: Context) void,
//     };
//     ptr: *anyopaque,
//     vtable: *const VTable,
//     pub fn new(ptr: anytype) Projection {
//         const T = @TypeOf(ptr);
//         const ptr_info = @typeInfo(T);

//         const gen = struct {
//             pub fn visitNullLiteralExpr(ctx: *anyopaque, expr: NullLiteralExpr, context: Context) void {
//                 const self: T = @ptrCast(@alignCast(ctx));
//                 return ptr_info.Pointer.child.visitNullLiteralExpr(self, expr, context);
//             }
//             pub fn visitBooleanLiteralExpr(ctx: *anyopaque, expr: BooleanLiteralExpr, context: Context) void {
//                 const self: T = @ptrCast(@alignCast(ctx));
//                 return ptr_info.Pointer.child.visitBooleanLiteralExpr(self, expr, context);
//             }
//             pub fn visitNumberLiteralExpr(ctx: *anyopaque, expr: NumberLiteralExpr, context: Context) void {
//                 const self: T = @ptrCast(@alignCast(ctx));
//                 return ptr_info.Pointer.child.visitNumberLiteralExpr(self, expr, context);
//             }
//             pub fn visitStringLiteralExpr(ctx: *anyopaque, expr: StringLiteralExpr, context: Context) void {
//                 const self: T = @ptrCast(@alignCast(ctx));
//                 return ptr_info.Pointer.child.visitStringLiteralExpr(self, expr, context);
//             }
//             pub fn visitObjectLiteralExpr(ctx: *anyopaque, expr: ObjectLiteralExpr, context: Context) void {
//                 const self: T = @ptrCast(@alignCast(ctx));
//                 return ptr_info.Pointer.child.visitObjectLiteralExpr(self, expr, context);
//             }
//             pub fn visitVarExpr(ctx: *anyopaque, expr: VarExpr, context: Context) void {
//                 const self: T = @ptrCast(@alignCast(ctx));
//                 return ptr_info.Pointer.child.visitVarExpr(self, expr, context);
//             }
//             pub fn visitHasAttributeExpr(ctx: *anyopaque, expr: HasAttributeExpr, context: Context) void {
//                 const self: T = @ptrCast(@alignCast(ctx));
//                 return ptr_info.Pointer.child.visitHasAttributeExpr(self, expr, context);
//             }
//             pub fn visitCallExpr(ctx: *anyopaque, expr: CallExpr, context: Context) void {
//                 const self: T = @ptrCast(@alignCast(ctx));
//                 return ptr_info.Pointer.child.visitCallExpr(self, expr, context);
//             }
//             pub fn visitLookupExpr(ctx: *anyopaque, expr: LookupExpr, context: Context) void {
//                 const self: T = @ptrCast(@alignCast(ctx));
//                 return ptr_info.Pointer.child.visitLookupExpr(self, expr, context);
//             }
//             pub fn visitMatchExpr(ctx: *anyopaque, expr: MatchExpr, context: Context) void {
//                 const self: T = @ptrCast(@alignCast(ctx));
//                 return ptr_info.Pointer.child.visitMatchExpr(self, expr, context);
//             }
//             pub fn visitCaseExpr(ctx: *anyopaque, expr: CaseExpr, context: Context) void {
//                 const self: T = @ptrCast(@alignCast(ctx));
//                 return ptr_info.Pointer.child.visitCaseExpr(self, expr, context);
//             }
//             pub fn visitStepExpr(ctx: *anyopaque, expr: StepExpr, context: Context) void {
//                 const self: T = @ptrCast(@alignCast(ctx));
//                 return ptr_info.Pointer.child.visitStepExpr(self, expr, context);
//             }
//             pub fn visitInterpolateExpr(ctx: *anyopaque, expr: InterpolateExpr, context: Context) void {
//                 const self: T = @ptrCast(@alignCast(ctx));
//                 return ptr_info.Pointer.child.visitInterpolateExpr(self, expr, context);
//             }
//         };
//         return .{
//             .ptr = ptr,
//             .vtable = &.{
//                 .visit = gen.visit,
//             },
//         };
//     }
//     pub fn visitNullLiteralExpr(this: *Self, expr: NullLiteralExpr, context: Context) void {
//         return this.vtable.visitNullLiteralExpr(this.ptr, expr, context);
//     }
//     pub fn visitBooleanLiteralExpr(this: *Self, expr: BooleanLiteralExpr, context: Context) void {
//         return this.vtable.visitBooleanLiteralExpr(this.ptr, expr, context);
//     }
//     pub fn visitNumberLiteralExpr(this: *Self, expr: NumberLiteralExpr, context: Context) void {
//         return this.vtable.visitNumberLiteralExpr(this.ptr, expr, context);
//     }
//     pub fn visitStringLiteralExpr(this: *Self, expr: StringLiteralExpr, context: Context) void {
//         return this.vtable.visitStringLiteralExpr(this.ptr, expr, context);
//     }
//     pub fn visitObjectLiteralExpr(this: *Self, expr: ObjectLiteralExpr, context: Context) void {
//         return this.vtable.visitObjectLiteralExpr(this.ptr, expr, context);
//     }
//     pub fn visitVarExpr(this: *Self, expr: VarExpr, context: Context) void {
//         return this.vtable.visitVarExpr(this.ptr, expr, context);
//     }
//     pub fn visitHasAttributeExpr(this: *Self, expr: HasAttributeExpr, context: Context) void {
//         return this.vtable.visitHasAttributeExpr(this.ptr, expr, context);
//     }
//     pub fn visitCallExpr(this: *Self, expr: CallExpr, context: Context) void {
//         return this.vtable.visitCallExpr(this.ptr, expr, context);
//     }
//     pub fn visitLookupExpr(this: *Self, expr: LookupExpr, context: Context) void {
//         return this.vtable.visitLookupExpr(this.ptr, expr, context);
//     }
//     pub fn visitMatchExpr(this: *Self, expr: MatchExpr, context: Context) void {
//         return this.vtable.visitMatchExpr(this.ptr, expr, context);
//     }
//     pub fn visitCaseExpr(this: *Self, expr: CaseExpr, context: Context) void {
//         return this.vtable.visitCaseExpr(this.ptr, expr, context);
//     }
//     pub fn visitStepExpr(this: *Self, expr: StepExpr, context: Context) void {
//         return this.vtable.visitStepExpr(this.ptr, expr, context);
//     }
//     pub fn visitInterpolateExpr(this: *Self, expr: InterpolateExpr, context: Context) void {
//         return this.vtable.visitInterpolateExpr(this.ptr, expr, context);
//     }
// }
