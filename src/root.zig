const std = @import("std");
const testing = std.testing;

test {
    _ = @import("./test/Expr.zig");
    _ = @import("./StringEncodedNumeral.zig");
}