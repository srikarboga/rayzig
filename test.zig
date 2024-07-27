const std = @import("std");

pub fn main() void {
    const scalar: comptime_float = 0.0;
    const result = @as(@Vector(4, f64), @splat(scalar));
    std.debug.print("{}", .{result});
}
