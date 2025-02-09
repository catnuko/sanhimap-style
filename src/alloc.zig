const std = @import("std");

var allocator: std.mem.Allocator = undefined;
var arena:*std.heap.ArenaAllocator = undefined;

pub fn init(alloc: std.mem.Allocator) void {
    arena = alloc.create(std.heap.ArenaAllocator) catch unreachable;
    arena.* = std.heap.ArenaAllocator.init(alloc);
    errdefer arena.deinit();
    allocator = arena.allocator();
}
pub fn deinit()void{
    const child_allocator = arena.child_allocator;
    arena.deinit();
    child_allocator.destroy(arena);
}

pub fn get() std.mem.Allocator {
    return allocator;
}
