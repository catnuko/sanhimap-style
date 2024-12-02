const std = @import("std");
const Value = std.json.Value;
pub const ValueMap = std.StringHashMap(Value);
const alloc = @import("./alloc.zig");
pub const MapEnv = struct {
    const Self = @This();
    entries: ValueMap,
    parent: *MapEnv,
    pub fn new(entries: ValueMap, parent: *MapEnv) Self {
        return Self{ .entries = entries, .parent = parent };
    }
    pub fn lookup(self: *Self, name: []const u8) ?Value {
        if (self.entries.get(name)) |value| {
            return value;
        } else {
            if (self.parent != null) {
                return self.parent.lookup(name);
            }
            return null;
        }
    }
    pub fn unmap(self: *Self) ValueMap {
        const obj = if (self.parent) |parent| parent.unmap() else ValueMap.init(alloc.get());
        var iter = self.entries.iterator();
        for (iter.next()) |entry| {
            obj.put(entry.key_ptr.*, entry.value_ptr.*) catch unreachable;
        }
        self.entries.deinit();
        return obj;
    }
};
