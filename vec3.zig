const std = @import("std");
const math = std.math;
const vec = @Vector(3, f64);
pub const Vec3 = struct {
    v: vec,

    pub fn init(x_init: f64, y_init: f64, z_init: f64) Vec3 {
        return .{ .v = vec{ x_init, y_init, z_init } };
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

    pub fn unit_vector(self: Vec3) Vec3 {
        return .{ .v = self.v / @as(vec, @splat(length(self))) };
    }

    pub fn dot(u: Vec3, self: Vec3) f64 {
        return @reduce(.Add, u.v * self.v);
    }

    pub fn cross(u: Vec3, self: Vec3) Vec3 {
        return Vec3{
            u[1] * self.v[2] - u[2] * self.v[1],
            u[2] * self.v[0] - u[0] * self.v[2],
            u[0] * self.v[1] - u[1] * self.v[0],
        };
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
