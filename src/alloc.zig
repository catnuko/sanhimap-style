const std = @import("std");

var allocator: std.mem.Allocator = undefined;

pub fn init(alloc: std.mem.Allocator) void {
    allocator = alloc;
}

pub fn get() std.mem.Allocator {
    return allocator;
}
