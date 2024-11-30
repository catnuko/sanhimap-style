const std = @import("std")
pub fn includes(a:[][]const u8,b:[]const u8)bool{
    for(a)|aa|{
        if(std.mem.eql(u8,aa,b)){
            return true;
        }
    }
    return false;
}