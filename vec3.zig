const std = @import("std");
const math = std.math;
const vec = @Vector(3, f64);
pub const Vec3 = struct {
    v: vec,

    pub fn init(x_init: f64, y_init: f64, z_init: f64) Vec3 {
        return .{ .v = vec{ x_init, y_init, z_init } };
    }

    pub fn random(min: f64, max: f64) Vec3 {
        const rand = std.crypto.random;
        return Vec3.init(min + (max - min) * rand.float(f64), min + (max - min) * rand.float(f64), min + (max - min) * rand.float(f64));
    }

    pub fn x(self: Vec3) f64 {
        return self.v[0];
    }

    pub fn y(self: Vec3) f64 {
        return self.v[1];
    }

    pub fn z(self: Vec3) f64 {
        return self.v[2];
    }

    pub fn length(self: Vec3) f64 {
        return @sqrt(length_squared(self));
    }

    pub fn length_squared(self: Vec3) f64 {
        return @reduce(.Add, self.v * self.v);
    }

    pub fn near_zero(self: Vec3) bool {
        const s = 1e-8;
        return (@abs(self.v[0]) < s and @abs(self.v[1]) < s and @abs(self.v[2]) < s);
    }

    pub fn unit_vector(self: Vec3) Vec3 {
        return .{ .v = self.v / @as(vec, @splat(length(self))) };
    }

    pub fn random_in_unit_disk() Vec3 {
        const rand = std.crypto.random;
        while (true) {
            const p = Vec3.init(2 * rand.float(f64) - 1, 2 * rand.float(f64) - 1, 0);
            if (p.length_squared() < 1) {
                return p;
            }
        }
    }

    pub fn random_in_unit_sphere() Vec3 {
        while (true) {
            const p = Vec3.random(-1, 1);
            if (p.length_squared() < 1) return p;
        }
    }

    pub fn random_on_hemisphere(normal: Vec3) Vec3 {
        const on_unit_sphere = random_unit_vector();
        if (on_unit_sphere.dot(normal) > 0.0) {
            return on_unit_sphere;
        } else {
            return on_unit_sphere.mul(-1);
        }
    }

    pub fn reflect(v: Vec3, n: Vec3) Vec3 {
        return v.sub(n.mul(Vec3.dot(v, n)).mul(2));
    }

    pub fn refract(uv: Vec3, n: Vec3, etai_over_etat: f64) Vec3 {
        const cos_theta = @min(uv.mul(-1).dot(n), 1.0);
        const r_out_perp = (uv.add(n.mul(cos_theta))).mul(etai_over_etat);
        const r_out_parallel = n.mul(-@sqrt(@abs(1.0 - r_out_perp.length_squared())));
        return r_out_perp.add(r_out_parallel);
    }

    pub fn random_unit_vector() Vec3 {
        return random_in_unit_sphere().unit_vector();
    }

    pub fn dot(u: Vec3, self: Vec3) f64 {
        return @reduce(.Add, u.v * self.v);
    }

    pub fn cross(u: Vec3, self: Vec3) Vec3 {
        return Vec3.init(
            u.v[1] * self.v[2] - u.v[2] * self.v[1],
            u.v[2] * self.v[0] - u.v[0] * self.v[2],
            u.v[0] * self.v[1] - u.v[1] * self.v[0],
        );
    }

    pub fn add(self: Vec3, other: anytype) Vec3 {
        switch (@TypeOf(other)) {
            comptime_int, i64, u64, usize => {
                return .{ .v = self.v + @as(vec, @splat(@floatFromInt(other))) };
            },
            comptime_float, f64 => {
                return .{ .v = self.v + @as(vec, @splat(other)) };
            },
            Vec3 => {
                return .{ .v = self.v + other.v };
            },
            else => {
                std.debug.print("Type: {}", .{@TypeOf(other)});
                @compileError("Unsupported type for addition");
            },
        }
    }

    pub fn sub(self: Vec3, other: anytype) Vec3 {
        switch (@TypeOf(other)) {
            comptime_int, i64, u64, usize => {
                return .{ .v = self.v - @as(vec, @splat(@floatFromInt(other))) };
            },
            comptime_float, f64 => {
                return .{ .v = self.v - @as(vec, @splat(other)) };
            },
            Vec3 => {
                return .{ .v = self.v - other.v };
            },
            else => {
                std.debug.print("Type: {}", .{@TypeOf(other)});
                @compileError("Unsupported type for subtraction");
            },
        }
    }

    pub fn mul(self: Vec3, other: anytype) Vec3 {
        switch (@TypeOf(other)) {
            comptime_int, i64, u64, usize => {
                return .{ .v = self.v * @as(vec, @splat(@floatFromInt(other))) };
            },
            comptime_float, f64 => {
                return .{ .v = self.v * @as(vec, @splat(other)) };
            },
            Vec3 => {
                return .{ .v = self.v * other.v };
            },
            else => {
                std.debug.print("Type: {}", .{@TypeOf(other)});
                @compileError("Unsupported type for multiplication");
            },
        }
    }

    pub fn div(self: Vec3, other: anytype) Vec3 {
        switch (@TypeOf(other)) {
            comptime_int, i64, u64, usize => {
                return .{ .v = self.v / @as(vec, @splat(@floatFromInt(other))) };
            },
            comptime_float, f64 => {
                return .{ .v = self.v / @as(vec, @splat(other)) };
            },
            Vec3 => {
                return .{ .v = self.v / other.v };
            },
            else => {
                std.debug.print("Type: {}", .{@TypeOf(other)});
                @compileError("Unsupported type for division");
            },
        }
    }
};

pub const Point3 = Vec3;

// pub fn main() void {
//     const v = Vec3.init(3, 1, -2);
//     std.debug.print("magnitude: {}", .{v.unit_vector()});
// }
