//Reference https://raytracing.github.io/books/RayTracingInOneWeekend.html
const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;
const Point3 = @import("vec3.zig").Point3;
const Ray = @import("ray.zig").Ray;
const ColorUtils = @import("./color.zig");
const Color = ColorUtils.Color;
const Sphere = @import("hittable.zig").Sphere;
const HitRecord = @import("hittable.zig").HitRecord;
const World = @import("hittable.zig").World;
const Interval = @import("interval.zig").Interval;
const Camera = @import("camera.zig").Camera;

pub fn main() !u8 {

    //World
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var world = World.init(allocator);
    defer world.deinit();
    try world.spheres.append(Sphere{ .center = Point3.init(0, 0, -1), .radius = 0.5 });
    try world.spheres.append(Sphere{ .center = Point3.init(0, -100.5, -1), .radius = 100 });

    var camera = Camera.init();
    try camera.render(&world);
    //printing basic info ab the image in ppm format
    return 0;
}
