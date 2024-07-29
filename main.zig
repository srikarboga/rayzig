//Reference https://raytracing.github.io/books/RayTracingInOneWeekend.html
const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;
const Point3 = @import("vec3.zig").Point3;
const Sphere = @import("hittable.zig").Sphere;
const World = @import("hittable.zig").World;
const Camera = @import("camera.zig").Camera;
const Material = @import("material.zig").Material;
const Color = @import("color.zig").Color;

pub fn main() !u8 {

    //World
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    var world = World.init(allocator);
    defer world.deinit();

    var material_ground = Material.Lambertian.init(Color.init(0.8, 0.8, 0.0));
    var material_center = Material.Lambertian.init(Color.init(0.1, 0.2, 0.5));
    var material_left = Material.Dielectric.init(1.5);
    var material_bubble = Material.Dielectric.init(1.00 / 1.50);
    var material_right = Material.Metal.init(Color.init(0.8, 0.6, 0.2), 1.0);

    try world.spheres.append(Sphere{ .center = Point3.init(0, -100.5, -1), .radius = 100, .mat = &material_ground });
    try world.spheres.append(Sphere{ .center = Point3.init(0, 0, -1.2), .radius = 0.5, .mat = &material_center });
    try world.spheres.append(Sphere{ .center = Point3.init(-1.0, 0, -1.0), .radius = 0.5, .mat = &material_left });
    try world.spheres.append(Sphere{ .center = Point3.init(-1.0, 0, -1.0), .radius = 0.4, .mat = &material_bubble });
    try world.spheres.append(Sphere{ .center = Point3.init(1.0, 0, -1.0), .radius = 0.5, .mat = &material_right });

    var camera = Camera.init();
    try camera.render(&world);
    //printing basic info ab the image in ppm format
    return 0;
}
