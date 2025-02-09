const json = @import("std").json;
pub const Tag = struct {
    pub const @"null" = 0;
    pub const @"bool" = 1;
    pub const integer = 2;
    pub const float = 3;
    pub const number_string = 4;
    pub const string = 5;
    pub const array = 6;
    pub const object = 7;
};

pub fn eql(a: *const json.Value, b: *const json.Value) bool {
    return @intFromEnum(a.*) == @intFromEnum(b.*);
}
