const std = @import("std");
const alloc = @import("./alloc.zig");
const exp = @import("Expr.zig");
const console = @import("./console.zig");
pub fn interpolatedPropertyDefinitionToJsonExpr(
    property: exp.InterpolatedPropertyDefinition,
) std.ArrayList(std.json.Value) {
    if (property.interpolation == undefined or property.interpolation == .Discrete) {
        const step = std.ArrayList(std.json.Value).init(alloc.get());
        step.append(.{ .string = "step" }) catch unreachable;
        step.append(.{.{ .string = "zoom" }}) catch unreachable;
        step.append(property.values[0]) catch unreachable;
        for (1..property.zoomLevels.length) |i| {
            step.append(property.zoomLevels[i]) catch unreachable;
            step.append(property.values[i]) catch unreachable;
        }
        return step;
    }
    const interpolation = std.ArrayList(std.json.Value).init(alloc.get());
    interpolation.append(.{ .string = "interpolate" }) catch unreachable;
    switch (property.interpolation) {
        .Linear => interpolation.append(.{ .string = "linear" }) catch unreachable,
        .Cubic => interpolation.append(.{ .string = "cubic" }) catch unreachable,
        .Exponential => {
            interpolation.append(.{ .string = "exponential" }) catch unreachable;
            interpolation.append(if (property.exponent != undefined) property.exponent else .{ .float = 2 }) catch unreachable;
        },
        else => console.panic("interpolation mode '{}' is not supported\n", .{property.interpolation}),
    }
    interpolation.append(.{ .string = "zoom" }) catch unreachable;
    for (0..property.zoomLevels.length) |i| {
        interpolation.append(property.zoomLevels[i]) catch unreachable;
        interpolation.append(property.values[i]) catch unreachable;
    }
    return interpolation;
}
