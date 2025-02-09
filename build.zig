const std = @import("std");
const Build = std.Build;
const ModuleImport = struct {
    module: ?*Build.Module,
    name: []const u8,
    linkLib: ?*Build.Step.Compile = null,
};
fn addImport(module: *std.Build.Module, imports: *const [4]ModuleImport) void {
    for (imports) |import| {
        if (import.module) |m| {
            module.addImport(import.name, m);
        }
        if (import.linkLib) |linkLib| {
            module.linkLibrary(linkLib);
        }
    }
}
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
    const string = b.dependency("string", .{
        .target = target,
        .optimize = optimize,
    });
    const zpcre2 = b.dependency("zpcre2", .{
        .target = target,
        .optimize = optimize,
    });
    const css_color_parser = b.dependency("css_color_parser", .{
        .target = target,
        .optimize = optimize,
    });
    //导入模块
    const imports = [_]ModuleImport{
        .{ .module = math.module("root"), .name = "math" },
        .{ .module = string.module("string"), .name = "string" },
        .{ .module = zpcre2.module("root"), .name = "zpcre2" },
        .{ .module = css_color_parser.module("root"), .name = "css_color_parser", .linkLib = css_color_parser.artifact("css-color-parser") },
    };
    addImport(root_mod, &imports);

    var lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    addImport(&lib_unit_tests.root_module, &imports);

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
