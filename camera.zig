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
const Material = @import("material.zig").Material;

pub const Camera = struct {
    aspect_ratio: f64,
    image_width: u64,
    image_height: u64,
    focal_length: f64,
    viewport_height: f64,
    viewport_width: f64,
    camera_center: Point3,
    viewport_u: Vec3,
    viewport_v: Vec3,
    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3,
    viewport_upper_left: Vec3,
    pixel00_loc: Vec3,
    samples_per_pixel: u64,
    pixel_samples_scale: f64,
    max_depth: u64,

    pub fn init() Camera {
        // Image
        const aspect_ratio: f64 = 16.0 / 9.0;
        const image_width = 400;
        const samples_per_pixel = 100;
        const max_depth = 50;
        const pixel_samples_scale = 1.0 / @as(f64, @floatFromInt(samples_per_pixel));
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
        return .{
            .aspect_ratio = aspect_ratio,
            .image_width = image_width,
            .image_height = image_height,
            .focal_length = focal_length,
            .viewport_height = viewport_height,
            .viewport_width = viewport_width,
            .camera_center = camera_center,
            .viewport_u = viewport_u,
            .viewport_v = viewport_v,
            .pixel_delta_u = pixel_delta_u,
            .pixel_delta_v = pixel_delta_v,
            .viewport_upper_left = viewport_upper_left,
            .pixel00_loc = pixel00_loc,
            .samples_per_pixel = samples_per_pixel,
            .pixel_samples_scale = pixel_samples_scale,
            .max_depth = max_depth,
        };
    }

    pub fn render(self: Camera, world: *World) !void {
        var stdout = std.io.getStdOut().writer();
        try stdout.print("P3\n{} {}\n255\n", .{ self.image_width, self.image_height });
        for (0..self.image_height) |j| {
            std.debug.print("\rScanlines remaining: {} ", .{self.image_height - j});
            for (0..self.image_width) |i| {
                var pixel_color = Color.init(0, 0, 0);
                for (0..self.samples_per_pixel) |_| {
                    const r = self.get_ray(i, j);
                    pixel_color = pixel_color.add(ray_color(r, world, self.max_depth));
                }
                // const pixel_center = self.pixel00_loc.add(self.pixel_delta_u.mul(i)).add(self.pixel_delta_v.mul(j));
                // const ray_direction = pixel_center.sub(self.camera_center);
                // const r = Ray.init(self.camera_center, ray_direction);
                //
                // const pcolor = ray_color(r, world);
                try ColorUtils.printColor(stdout, pixel_color.mul(self.pixel_samples_scale));
            }
        }
        std.debug.print("\rDone                      \n", .{});
    }

    pub fn ray_color(r: Ray, world: *World, depth: u64) Color {
        if (depth <= 0) {
            return Color.init(0, 0, 0);
        }
        var rec: HitRecord = undefined;
        if (world.hit(Interval.init(0.001, 10000), &rec, r)) {
            var scattered: Ray = undefined;
            var attenuation: Color = undefined;
            switch (rec.mat.*) {
                .Lambertian => {
                    if (rec.mat.*.Lambertian.scatter(r, &rec, &attenuation, &scattered)) return attenuation.mul(ray_color(scattered, world, depth - 1));
                    return Color.init(0, 0, 0);
                },
                .Metal => {
                    if (rec.mat.*.Metal.scatter(r, &rec, &attenuation, &scattered)) return attenuation.mul(ray_color(scattered, world, depth - 1));
                    return Color.init(0, 0, 0);
                },
            }

            // const direction = Vec3.random_unit_vector().add(rec.normal);
            // return ray_color(Ray.init(rec.p, direction), world, depth - 1).mul(0.5);
            // return rec.normal.add(Color.init(1, 1, 1)).mul(0.5);
        }
        const unit_direction = r.direction().unit_vector();
        const a = 0.5 * (unit_direction.y() + 1.0);
        // std.debug.print("a: {}, y: {}\n", .{ a, unit_direction.y() });
        return (Color.init(1.0, 1.0, 1.0).mul(1.0 - a)).add(Color.init(0.5, 0.7, 1.0).mul(a));
    }

    pub fn get_ray(self: Camera, i: usize, j: usize) Ray {
        const offset = sample_square();
        const pixel_sample = self.pixel00_loc.add(self.pixel_delta_u.mul(offset.x() + @as(f64, @floatFromInt(i)))).add(self.pixel_delta_v.mul(offset.y() + @as(f64, @floatFromInt(j))));
        const ray_origin = self.camera_center;
        const ray_direction = pixel_sample.sub(ray_origin);

        return Ray.init(ray_origin, ray_direction);
    }

    pub fn sample_square() Vec3 {
        const rand = std.crypto.random;
        return Vec3.init(rand.float(f64) - 0.5, rand.float(f64) - 0.5, 0);
    }
};
