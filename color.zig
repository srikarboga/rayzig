const Vec3 = @import("vec3.zig").Vec3;
const std = @import("std");

pub const Color = Vec3;
pub fn printColor(writer: anytype, color: Color) !void {
    // std.debug.print("{}\n", .{color.x()});
    const ir = @as(i64, @intFromFloat(255.999 * color.x()));
    const ig = @as(i64, @intFromFloat(255.999 * color.y()));
    const ib = @as(i64, @intFromFloat(255.999 * color.z()));

    try writer.print("{} {} {}\n", .{ ir, ig, ib });
}
