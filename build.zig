const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const root_mod = b.addModule("sanhimap-style", .{
        .root_source_file = b.path("./src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const math = b.dependency("math", .{
        .target = target,
        .optimize = optimize,
    });
    root_mod.addImport("math", math.module("root"));
    
    const string = b.dependency("string", .{
        .target = target,
        .optimize = optimize,
    });
    root_mod.addImport("string", string.module("string"));

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
