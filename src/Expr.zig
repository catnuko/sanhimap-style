pub const Context = struct{

}
pub const Expr = struct {
    const Self = @This();
    pub const VTable = struct {
        accept: *const fn (ctx: *anyopaque, visitor: f64, context: f64) void,
    };
    ptr: *anyopaque,
    vtable: *const VTable,
    pub fn new(ptr: anytype) Projection {
        const T = @TypeOf(ptr);
        const ptr_info = @typeInfo(T);

        const gen = struct {
            pub fn accept(ctx: *anyopaque, visitor: f64, context: f64) void {
                const self: T = @ptrCast(@alignCast(ctx));
                return ptr_info.Pointer.child.accept(self, visitor, context);
            }
            pub fn exprIsDynamic(ctx: *anyopaque)bool {
                const self: T = @ptrCast(@alignCast(ctx));
                return ptr_info.Pointer.child.exprIsDynamic(self);
            }
        };
        return .{
            .ptr = ptr,
            .vtable = &.{
                .accept = gen.accept,
            },
        };
    }
    pub fn evaluate(this: *Self,env:Env,scope:ExprScope,cache:?Cache) Value {
        return this.accept()
    }
    pub fn accept(this: *Self, visitor: f64, context: f64) void {
        return this.vtable.accept(this.ptr, visitor, context);
    }
    pub fn exprIsDynamic(this: *Self) bool {
        return this.vtable.exprIsDynamic(this.ptr);
    }
};