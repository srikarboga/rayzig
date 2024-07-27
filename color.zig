const Vec3 = @import("vec3.zig").Vec3;

pub const Color = Vec3;
pub fn printColor(writer: anytype, color: Color) !void {
    const ir = @as(u64, @intFromFloat(255.999 * color.x()));
    const ig = @as(u64, @intFromFloat(255.999 * color.y()));
    const ib = @as(u64, @intFromFloat(255.999 * color.z()));

    try writer.print("{} {} {}\n", .{ ir, ig, ib });
}
