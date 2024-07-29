const Vec3 = @import("vec3.zig").Vec3;
const std = @import("std");
const Interval = @import("interval.zig").Interval;

pub const Color = Vec3;
pub fn printColor(writer: anytype, color: Color) !void {
    // std.debug.print("{}\n", .{color.x()});
    const r = color.x();
    const g = color.y();
    const b = color.z();

    const intensity = Interval.init(0.000, 0.999);
    const rbyte: i64 = @intFromFloat(256 * intensity.clamp(r));
    const gbyte: i64 = @intFromFloat(256 * intensity.clamp(g));
    const bbyte: i64 = @intFromFloat(256 * intensity.clamp(b));
    try writer.print("{} {} {}\n", .{ rbyte, gbyte, bbyte });
}
