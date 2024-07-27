//Reference https://raytracing.github.io/books/RayTracingInOneWeekend.html
const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;
const Point3 = @import("vec3.zig").Point3;
const Ray = @import("ray.zig").Ray;
const ColorUtils = @import("./color.zig");
const Color = ColorUtils.Color;

pub fn hit_sphere(center: Point3, radius: f64, r: Ray) f64 {
    const oc = center.sub(r.origin());
    const a = r.direction().dot(r.direction());
    const b = r.direction().dot(oc) * (-2.0);
    const c = oc.dot(oc) - (radius * radius);
    const discriminant = (b * b) - (4 * a * c);
    if (discriminant < 0) {
        return -1.0;
    } else {
        return (-b - @sqrt(discriminant)) / (2.0 * a);
    }
}

pub fn ray_color(r: Ray) Color {
    const t = hit_sphere(Point3.init(0, 0, -1), 0.5, r);
    if (t > 0.0) {
        const normal = r.at(t).sub(Vec3.init(0, 0, -1)).unit_vector();
        return Color.init(normal.x() + 1, normal.y() + 1, normal.z() + 1).mul(0.5);
    }

    const unit_direction = r.direction().unit_vector();
    const a = 0.5 * (unit_direction.y() + 1.0);
    // std.debug.print("a: {}, y: {}\n", .{ a, unit_direction.y() });
    return (Color.init(1.0, 1.0, 1.0).mul(1.0 - a)).add(Color.init(0.5, 0.7, 1.0).mul(a));
}

pub fn main() !u8 {

    // Image
    const aspect_ratio: f64 = 16.0 / 9.0;
    const image_width = 400;

    // image_height calculation using aspect ratio
    var image_height = @as(u64, @intFromFloat(@as(f64, @floatFromInt(image_width)) / aspect_ratio));
    image_height = if (image_height < 1) 1 else image_height;

    // Camera

    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * (@as(f64, @floatFromInt(image_width)) / @as(f64, @floatFromInt(image_height)));
    const camera_center = Point3.init(0, 0, 0);

    // Caclulate the vectors accross the horizontal and down the vertical viewport edges
    const viewport_u = Vec3.init(viewport_width, 0, 0);
    const viewport_v = Vec3.init(0, -viewport_height, 0);

    // Calculate the vectors across teh horizontal and down the vertical viewport edges.
    const pixel_delta_u = viewport_u.div(image_width);
    const pixel_delta_v = viewport_v.div(image_height);

    // Calculate the location of the upper left pixel
    const viewport_upper_left = camera_center.sub(Vec3.init(0, 0, focal_length)).sub(viewport_u.div(2)).sub(viewport_v.div(2));

    //pixel 0,0 - the first pixel location
    //BE VERY CAREFUL WITH EXPRESSIONS SUCH AS THIS ONE, VERY EASY TO MESS UP WITHOUT OPERATOR OVERLOADING.
    const pixel00_loc = pixel_delta_u.add(pixel_delta_v).mul(0.5).add(viewport_upper_left);
    //Render

    //printing basic info ab the image in ppm format
    var stdout = std.io.getStdOut().writer();
    try stdout.print("P3\n{} {}\n255\n", .{ image_width, image_height });
    for (0..image_height) |j| {
        std.debug.print("\rScanlines remaining: {} ", .{image_height - j});
        for (0..image_width) |i| {
            const pixel_center = pixel00_loc.add(pixel_delta_u.mul(i)).add(pixel_delta_v.mul(j));
            const ray_direction = pixel_center.sub(camera_center);
            const r = Ray.init(camera_center, ray_direction);

            const pcolor = ray_color(r);
            try ColorUtils.printColor(stdout, pcolor);
        }
    }
    std.debug.print("\rDone                      \n", .{});
    return 0;
}
