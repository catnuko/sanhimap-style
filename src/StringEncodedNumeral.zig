const std = @import("std");
const alloc = @import("./alloc.zig");
const Regex = @import("zpcre2").Regex;
const colorUtils = @import("./ColorUtils.zig");
const parse = @import("css_color_parser").parse;
pub const StringEncodedNumeralType = enum {
    hex,
    pixels,
    meters,
};
pub const StringEncodedColorFormat = struct {
    ty: StringEncodedNumeralType,
    size: u32,
    pattern: []const u8,
    regex: Regex = undefined,
    mask: ?u32 = null,
    decoder: *const fn (encodedValue: []const u8, target: *[StringEncodedNumeralFormatMaxSize]f64) bool,
};

pub var StringEncodedMeters = StringEncodedColorFormat{
    .ty = StringEncodedNumeralType.meters,
    .size = 1,
    .pattern = "^((?=\\.\\d|\\d)(?:\\d+)?(?:\\.?\\d*))m$",
    .decoder = struct {
        pub fn call(encodedValue: []const u8, target: *[StringEncodedNumeralFormatMaxSize]f64) bool {
            const allocator = alloc.get();
            const caps = StringEncodedMeters.regex.match(allocator, encodedValue) orelse {
                return false;
            };
            defer allocator.free(caps);
            if (caps[1]) |cap| {
                const value = encodedValue[cap.start..cap.end];
                target[0] = std.fmt.parseFloat(f64, value) catch unreachable;
                return true;
            } else {
                return false;
            }
        }
    }.call,
};
pub var StringEncodedPixels = StringEncodedColorFormat{
    .ty = StringEncodedNumeralType.pixels,
    .size = 1,
    .mask = 1,
    .pattern = "^((?=\\.\\d|\\d)(?:\\d+)?(?:\\.?\\d*))px$",
    .decoder = struct {
        pub fn call(encodedValue: []const u8, target: *[StringEncodedNumeralFormatMaxSize]f64) bool {
            const allocator = alloc.get();
            const caps = StringEncodedPixels.regex.match(allocator, encodedValue) orelse {
                return false;
            };
            defer allocator.free(caps);
            if (caps[1]) |cap| {
                const value = encodedValue[cap.start..cap.end];
                target[0] = std.fmt.parseFloat(f64, value) catch unreachable;
                return true;
            } else {
                return false;
            }
        }
    }.call,
};
pub var StringEncodedHex = StringEncodedColorFormat{
    .ty = StringEncodedNumeralType.hex,
    .size = 4,
    .pattern = "^\\#((?:[0-9A-Fa-f][0-9A-Fa-f]){4}|[0-9A-Fa-f]{4})$",
    .decoder = struct {
        pub fn call(encodedValue: []const u8, target: *[StringEncodedNumeralFormatMaxSize]f64) bool {
            const allocator = alloc.get();
            const caps = StringEncodedHex.regex.match(allocator, encodedValue) orelse {
                return false;
            };
            defer allocator.free(caps);
            const cap = caps[1] orelse return false;
            const hex = encodedValue[cap.start..cap.end];
            const size = hex.len;
            std.testing.expect(size == 4 or size == 8) catch return false;
            if (size == 4) {
                target[0] = parseInt(hex[0], hex[0]) / 255.0;
                target[1] = parseInt(hex[1], hex[1]) / 255.0;
                target[2] = parseInt(hex[2], hex[2]) / 255.0;
                target[3] = if (size == 4) parseInt(hex[3], hex[3]) / 255.0 else 1;
            } else if (size == 8) {
                target[0] = parseInt(hex[0], hex[1]) / 255.0;
                target[1] = parseInt(hex[2], hex[3]) / 255.0;
                target[2] = parseInt(hex[4], hex[5]) / 255.0;
                target[3] = if (size == 8) parseInt(hex[6], hex[7]) / 255.0 else 1;
            }
            return true;
        }
    }.call,
};
fn parseInt(a: u8, b: u8) f64 {
    const buf = [_]u8{ a, b };
    const int = std.fmt.parseInt(i32, &buf, 16) catch unreachable;
    return @floatFromInt(int);
}
pub const StringEncodedMetricFormatMaxSize: u32 = 1;
pub const StringEncodedColorFormatMaxSize: u32 = 4;
pub const StringEncodedNumeralFormatMaxSize = @max(StringEncodedMetricFormatMaxSize, StringEncodedColorFormatMaxSize);
var tmpBuffer = [_]f64{0} ** StringEncodedNumeralFormatMaxSize;

pub var StringEncodedMetricFormats = [_]*StringEncodedColorFormat{
    &StringEncodedMeters,
    &StringEncodedPixels,
};
pub var StringEncodedColorFormats = [_]*StringEncodedColorFormat{
    &StringEncodedHex,
};
pub var StringEncodedNumeralFormats = [_]*StringEncodedColorFormat{
    &StringEncodedMeters,
    &StringEncodedPixels,
    &StringEncodedHex,
};

pub fn init() void {
    for (StringEncodedNumeralFormats) |format| {
        format.regex = Regex.compile(format.pattern) catch unreachable;
    }
}
pub fn deinit() void {
    for (StringEncodedNumeralFormats) |format| {
        format.regex.deinit();
    }
}
pub fn parseStringEncodedNumeral(text: []const u8, pixelToMeters: ?f64) ?f64 {
    return parseStringLiteral(text, &StringEncodedNumeralFormats, pixelToMeters orelse 1.0);
}
pub fn parseStringEncodedColor(color: []const u8) ?f64 {
    return parseStringLiteral(color, StringEncodedColorFormats, 1.0);
}
pub fn parseStringLiteral(text: []const u8, formats: []*StringEncodedColorFormat, pixelToMeters: f64) ?f64 {
    var ty: ?StringEncodedNumeralType = null;
    for (0..formats.len) |i| {
        const format = formats[i];
        if (format.decoder(text, &tmpBuffer)) {
            ty = format.ty;
            break;
        }
    }
    if (ty) |types| {
        switch (types) {
            StringEncodedNumeralType.pixels => {
                return tmpBuffer[0] * pixelToMeters;
            },
            StringEncodedNumeralType.hex => {
                return colorUtils.getHexFromRgba(tmpBuffer[0], tmpBuffer[1], tmpBuffer[2], tmpBuffer[3]);
            },
            else => {
                return tmpBuffer[0];
            },
        }
    } else {
        const color = parse(text);
        if (color) |c| {
            return colorUtils.getHexFromRgba(
                @as(f64, @floatFromInt(c.r)) / 255.0,
                @as(f64, @floatFromInt(c.g)) / 255.0,
                @as(f64, @floatFromInt(c.b)) / 255.0,
                c.a,
            );
        }
        return null;
    }
}

const testing = @import("./testing.zig");
test "test.metric" {
    testing.init();
    defer testing.deinit();
    try testing.expect(parseStringEncodedNumeral("0m", null).? == 0.0);
    try testing.expect(parseStringEncodedNumeral("0.m", null).? == 0.0);
    try testing.expect(parseStringEncodedNumeral("0.0m", null).? == 0.0);
    try testing.expect(parseStringEncodedNumeral("0.1m", null).? == 0.1);
    try testing.expect(parseStringEncodedNumeral("0.000000001m", null).? == 0.000000001);
    try testing.expect(parseStringEncodedNumeral("0.123456789m", null).? == 0.123456789);

    try testing.expect(parseStringEncodedNumeral("1m", null).? == 1.0);
    try testing.expect(parseStringEncodedNumeral("1.m", null).? == 1.0);
    try testing.expect(parseStringEncodedNumeral("1.0m", null).? == 1.0);
    try testing.expect(parseStringEncodedNumeral("1.1m", null).? == 1.1);
    try testing.expect(parseStringEncodedNumeral("1.000000001m", null).? == 1.000000001);
    try testing.expect(parseStringEncodedNumeral("1.123456789m", null).? == 1.123456789);

    try testing.expect(parseStringEncodedNumeral("123456789m", null).? == 123456789);
    try testing.expect(parseStringEncodedNumeral("123456789.m", null).? == 123456789);
    try testing.expect(parseStringEncodedNumeral("123456789.0m", null).? == 123456789);

    try testing.expect(parseStringEncodedNumeral("+10m", null) == null);
    try testing.expect(parseStringEncodedNumeral("-10m", null) == null);
    try testing.expect(parseStringEncodedNumeral("- 10m", null) == null);

    try testing.expect(parseStringEncodedNumeral("10m in wrong format", null) == null);
    try testing.expect(parseStringEncodedNumeral(" 10m", null) == null);
    try testing.expect(parseStringEncodedNumeral("10m ", null) == null);
    try testing.expect(parseStringEncodedNumeral("10 m", null) == null);
}
