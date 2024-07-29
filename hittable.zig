const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;
const Point3 = @import("vec3.zig").Point3;
const Ray = @import("ray.zig").Ray;
const ArrayList = std.ArrayList;
const Interval = @import("interval.zig").Interval;
const Material = @import("material.zig").Material;

pub const HitRecord = struct {
    p: Point3,
    normal: Vec3,
    t: f64,
    front_face: bool,
    mat: *Material,

    pub fn setFaceNormal(self: *HitRecord, r: Ray, outward_normal: Vec3) void {
        self.front_face = r.direction().dot(outward_normal) < 0;
        self.normal = if (self.front_face) outward_normal else outward_normal.mul(-1);
    }
};

pub const Sphere = struct {
    center: Point3,
    radius: f64,
    mat: *Material,

    pub fn hit(self: Sphere, ray_t: Interval, rec: *HitRecord, r: Ray) bool {
        const oc = self.center.sub(r.origin());
        const a = r.direction().length_squared();
        const h = r.direction().dot(oc);
        const c = oc.length_squared() - (self.radius * self.radius);
        const discriminant = (h * h) - (a * c);
        if (discriminant < 0)
            return false;

        const sqrtd = @sqrt(discriminant);

        var root = (h - sqrtd) / a;
        if (!ray_t.surrounds(root)) {
            root = (h + sqrtd) / a;
            if (!ray_t.surrounds(root))
                return false;
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        rec.normal = (rec.p.sub(self.center)).div(self.radius);
        const outward_normal = rec.p.sub(self.center).div(self.radius);
        rec.setFaceNormal(r, outward_normal);
        rec.mat = self.mat;

        return true;
    }
};

pub const World = struct {
    spheres: ArrayList(Sphere),

    pub fn init(allocator: std.mem.Allocator) World {
        return World{ .spheres = ArrayList(Sphere).init(allocator) };
    }

    pub fn deinit(self: *World) void {
        self.spheres.deinit();
    }

    pub fn hit(self: *World, ray_t: Interval, hit_rec: *HitRecord, ray: Ray) bool {
        var maybe_hit: HitRecord = undefined;
        var hit_anything = false;
        var closest_so_far = ray_t.max;

        for (self.spheres.items) |sphere| {
            if (sphere.hit(Interval.init(ray_t.min, closest_so_far), &maybe_hit, ray)) {
                hit_anything = true;
                closest_so_far = maybe_hit.t;
                hit_rec.* = maybe_hit;
            }
        }

        return hit_anything;
    }
};
