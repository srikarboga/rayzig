const Vec3 = @import("vec3.zig").Vec3;
const std = @import("std");
const Interval = @import("interval.zig").Interval;

pub const Color = Vec3;

pub fn linear_to_gamma(linear_component: f64) f64 {
    if (linear_component > 0) return @sqrt(linear_component);
    return 0;
}

pub fn printColor(writer: anytype, color: Color) !void {
    // std.debug.print("{}\n", .{color.x()});
    var r = color.x();
    var g = color.y();
    var b = color.z();

    r = linear_to_gamma(r);
    g = linear_to_gamma(g);
    b = linear_to_gamma(b);

    const intensity = Interval.init(0.000, 0.999);
    const rbyte: i64 = @intFromFloat(256 * intensity.clamp(r));
    const gbyte: i64 = @intFromFloat(256 * intensity.clamp(g));
    const bbyte: i64 = @intFromFloat(256 * intensity.clamp(b));
    try writer.print("{} {} {}\n", .{ rbyte, gbyte, bbyte });
}
