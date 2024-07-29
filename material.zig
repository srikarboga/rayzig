const Ray = @import("ray.zig").Ray;
const ColorUtils = @import("./color.zig");
const Color = ColorUtils.Color;
const HitRecord = @import("hittable.zig").HitRecord;
const Vec3 = @import("vec3.zig").Vec3;

pub const Material = union(enum) {
    Lambertian: Lambertian,
    Metal: Metal,

    pub const Lambertian = struct {
        albedo: Color,

        pub fn init(albedo: Color) Material {
            return .{ .Lambertian = .{ .albedo = albedo } };
        }

        pub fn scatter(self: Lambertian, r_in: Ray, hit_record: *HitRecord, attenuation: *Color, scattered: *Ray) bool {
            _ = r_in;
            var scatter_direction = hit_record.normal.add(Vec3.random_unit_vector());
            if (scatter_direction.near_zero()) scatter_direction = hit_record.normal;
            scattered.* = Ray.init(hit_record.p, scatter_direction);
            attenuation.* = self.albedo;
            return true;
        }
    };

    pub const Metal = struct {
        albedo: Color,
        fuzz: f64,

        pub fn init(albedo: Color, fuzz: f64) Material {
            return .{ .Metal = .{ .albedo = albedo, .fuzz = fuzz } };
        }

        pub fn scatter(self: Metal, r_in: Ray, hit_record: *HitRecord, attenuation: *Color, scattered: *Ray) bool {
            var reflected = Vec3.reflect(r_in.direction(), hit_record.normal);
            reflected = reflected.unit_vector().add(Vec3.random_unit_vector().mul(self.fuzz));
            scattered.* = Ray.init(hit_record.p, reflected);
            attenuation.* = self.albedo;
            return (scattered.direction().dot(hit_record.normal) > 0);
        }
    };
};
