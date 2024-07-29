const std = @import("std");
const Ray = @import("ray.zig").Ray;
const ColorUtils = @import("./color.zig");
const Color = ColorUtils.Color;
const HitRecord = @import("hittable.zig").HitRecord;
const Vec3 = @import("vec3.zig").Vec3;

pub const Material = union(enum) {
    Lambertian: Lambertian,
    Metal: Metal,
    Dielectric: Dielectric,

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

    pub const Dielectric = struct {
        refraction_index: f64,

        pub fn init(refraction_index: f64) Material {
            return .{ .Dielectric = .{ .refraction_index = refraction_index } };
        }

        pub fn scatter(self: Dielectric, r_in: Ray, hit_record: *HitRecord, attenuation: *Color, scattered: *Ray) bool {
            attenuation.* = Color.init(1.0, 1.0, 1.0);
            const ri = if (hit_record.front_face) (1.0 / self.refraction_index) else self.refraction_index;

            const unit_direction = r_in.direction().unit_vector();
            const cos_theta = @min(unit_direction.mul(-1).dot(hit_record.normal), 1.0);
            const sin_theta = @sqrt(1.0 - cos_theta * cos_theta);

            const cannot_refract = ri * sin_theta > 1.0;
            var direction: Vec3 = undefined;

            // const refracted = Vec3.refract(unit_direction, hit_record.normal, ri);
            const rand = std.crypto.random;
            if (cannot_refract or reflectance(cos_theta, ri) > rand.float(f64)) {
                direction = Vec3.reflect(unit_direction, hit_record.normal);
            } else {
                direction = Vec3.refract(unit_direction, hit_record.normal, ri);
            }
            scattered.* = Ray.init(hit_record.p, direction);
            return true;
        }

        pub fn reflectance(cosine: f64, refraction_index: f64) f64 {
            var r0 = (1 - refraction_index) / (1 + refraction_index);
            r0 = r0 * r0;
            return r0 + (1 - r0) * (std.math.pow(f64, (1 - cosine), 5));
        }
    };
};
