const std = @import("std");
pub fn codePointAt(string: []const u8, index: usize)?u21{
    const real_index = getIndex(string,index,true) orelse unreachable;
    const size = getUTF8Size(string[real_index]);
    return std.unicode.utf8Decode(string[real_index..real_index+size]) catch null;
}
/// Returns the real index of a unicode string literal
pub fn getIndex(string: []const u8, index: usize, real: bool) ?usize {
    var i: usize = 0;
    var j: usize = 0;
    while (i < string.len) {
        if (real) {
            if (j == index) return i;
        } else {
            if (i == index) return j;
        }
        i += getUTF8Size(string[i]);
        j += 1;
    }
    return null;
}
/// Returns the UTF-8 character's size
pub inline fn getUTF8Size(char: u8) u3 {
    return std.unicode.utf8ByteSequenceLength(char) catch {
        return 1;
    };
}
/// Checks if byte is part of UTF-8 character
pub inline fn isUTF8Byte(byte: u8) bool {
    return ((byte & 0x80) > 0) and (((byte << 1) & 0x80) == 0);
}
pub fn substringClone(allocator:std.mem.Allocator,string: []const u8, start: usize, end: usize) ![]const u8 {
    const str = substring(string, start, end);
    return try allocator.dupe(u8, str);
}
pub fn substring(string: []const u8, start: usize, end: usize) []const u8 {
    const vStart = @min(start, end);
    const vEnd = @max(start, end);
    if(vStart==vEnd) return "";
    if(getIndex(string,vStart,true))|rStart|{
        if(getIndex(string,vEnd,true))|rEnd|{
            return string[rStart..rEnd];
        }else{
            std.debug.print("end index out of range\n",.{});
            return ""
        }
    }else{
        std.debug.print("start index out of range\n",.{});
        return ""
    }
}
test "string.substring" {
    const str = "你好,hello,world";
    {
        const expected = "你好";
        const result = substring(str,0,2);
        try std.testing.expectEqualStrings(expected, result);
    }
    {
        const expected = "你好";
        const result = substring(str,2,0);
        try std.testing.expectEqualStrings(expected, result);
    }
    {
        const expected = "hello";
        const result = substring(str,3,8);
        try std.testing.expectEqualStrings(expected, result);
    }
    {
        const expected = "hello";
        const result = substring(str,8,3);
        try std.testing.expectEqualStrings(expected, result);
    }
}
test "string.codePointAt" {
    const str = "你好,hello,world";
    var results = [1]u21{0} ** 14;
    for(0..14) |i| {
        results[i] = codePointAt(str,i) orelse unreachable;
    }
    const expected = [_]u21{ '你', '好', ',', 'h', 'e', 'l', 'l', 'o', ',', 'w', 'o', 'r', 'l', 'd' };
    try std.testing.expectEqualSlices(u21, &expected, &results);
    const expected2 = [_]u21{ 
        20320,
        22909,
        44,
        104,
        101,
        108,
        108,
        111,
        44,
        119,
        111,
        114,
        108,
        100
    };
    try std.testing.expectEqualSlices(u21, &expected2, &results);
    try std.testing.expectEqualSlices(u21, &expected, &expected2);
    
}