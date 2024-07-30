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

    // Scene before final render
    // const material_ground = Material.Lambertian.init(Color.init(0.8, 0.8, 0.0));
    // const material_center = Material.Lambertian.init(Color.init(0.1, 0.2, 0.5));
    // const material_left = Material.Dielectric.init(1.5);
    // const material_bubble = Material.Dielectric.init(1.00 / 1.50);
    // const material_right = Material.Metal.init(Color.init(0.8, 0.6, 0.2), 1.0);
    //
    // try world.spheres.append(Sphere{ .center = Point3.init(0, -100.5, -1), .radius = 100, .mat = material_ground });
    // try world.spheres.append(Sphere{ .center = Point3.init(0, 0, -1.2), .radius = 0.5, .mat = material_center });
    // try world.spheres.append(Sphere{ .center = Point3.init(-1.0, 0, -1.0), .radius = 0.5, .mat = material_left });
    // try world.spheres.append(Sphere{ .center = Point3.init(-1.0, 0, -1.0), .radius = 0.4, .mat = material_bubble });
    // try world.spheres.append(Sphere{ .center = Point3.init(1.0, 0, -1.0), .radius = 0.5, .mat = material_right });

    //Final render

    const ground_material = Material.Lambertian.init(Color.init(0.5, 0.5, 0.5));
    try world.spheres.append(Sphere{ .center = Point3.init(0, -1000, 0), .radius = 1000, .mat = ground_material });

    const rand = std.crypto.random;
    var a: f64 = -5;
    while (a < 5) : (a += 1) {
        var b: f64 = -5;
        while (b < 5) : (b += 1) {
            const choose_mat = rand.float(f64);
            // std.debug.print("{} \n", .{choose_mat});
            const center = Point3.init(a + 0.9 * rand.float(f64), 0.2, b + 0.9 * rand.float(f64));

            if ((center.sub(Point3.init(4, 0.2, 0))).length() > 0.9) {
                if (choose_mat < 0.8) {
                    const albedo = Color.random(0, 1).mul(Color.random(0, 1));
                    // std.debug.print("{} {} {} \n", .{ albedo.x(), albedo.y(), albedo.z() });
                    try world.spheres.append(Sphere{ .center = center, .radius = 0.2, .mat = Material.Lambertian.init(albedo) });
                } else if (choose_mat < 0.95) {
                    const albedo = Color.random(0.5, 1);
                    const fuzz = 0.5 * rand.float(f64);
                    try world.spheres.append(Sphere{ .center = center, .radius = 0.2, .mat = Material.Metal.init(albedo, fuzz) });
                } else {
                    try world.spheres.append(Sphere{ .center = center, .radius = 0.2, .mat = Material.Dielectric.init(1.5) });
                }
            }
        }
    }

    const material1 = Material.Dielectric.init(1.5);
    try world.spheres.append(Sphere{ .center = Point3.init(0, 1, 0), .radius = 1.0, .mat = material1 });

    const material2 = Material.Lambertian.init(Color.init(0.4, 0.2, 0.1));
    try world.spheres.append(Sphere{ .center = Point3.init(-4, 1, 0), .radius = 1.0, .mat = material2 });

    const material3 = Material.Metal.init(Color.init(0.7, 0.6, 0.5), 0.0);
    try world.spheres.append(Sphere{ .center = Point3.init(4, 1, 0), .radius = 1.0, .mat = material3 });

    var camera = Camera.init();
    try camera.render(&world);
    //printing basic info ab the image in ppm format
    return 0;
}
