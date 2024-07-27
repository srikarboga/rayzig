const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;
const Point3 = @import("vec3.zig").Point3;
const Color = @import("color.zig").Color;

pub const Ray = struct {
    orig: Point3,
    dir: Vec3,

    pub fn init(origin_init: Point3, direction_init: Vec3) Ray {
        return .{
            .orig = origin_init,
            .dir = direction_init,
        };
    }

    pub fn origin(self: Ray) Vec3 {
        return self.orig;
    }
    pub fn direction(self: Ray) Vec3 {
        return self.dir;
    }

    pub fn at(self: Ray, t: f64) Vec3 {
        return self.orig + @as(Vec3, @splat(t)) * self.dir;
    }

    pub fn ray_color(r: Ray) Color {
        const unit_direction = r.direction().unit_vector();
        const a = 0.5 * (unit_direction.y() + 1.0);
        // std.debug.print("a: {}, y: {}\n", .{ a, unit_direction.y() });
        return (Color.init(1.0, 1.0, 1.0).mul(1.0 - a)).add(Color.init(0.5, 0.7, 1.0).mul(a));
    }
};
