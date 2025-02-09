const std = @import("std");
const alloc = @import("./alloc.zig");
const ExprEvaluator = @import("./ExprEvaluator.zig");
const StringEncodedNumeral = @import("./StringEncodedNumeral.zig");
pub usingnamespace std.testing;
pub fn init() void {
    alloc.init(std.testing.allocator);
    ExprEvaluator.init();
    StringEncodedNumeral.init();
}

pub fn deinit()void{
    StringEncodedNumeral.deinit();
    ExprEvaluator.deinit();
    alloc.deinit();
}
