pub const Interval = struct {
    min: f64,
    max: f64,

    pub fn init(min: f64, max: f64) Interval {
        return .{ .min = min, .max = max };
    }

    pub fn size(self: Interval) f64 {
        return self.max - self.min;
    }

    pub fn contains(self: Interval, x: f64) bool {
        return self.min <= x and x <= self.max;
    }

    pub fn surrounds(self: Interval, x: f64) bool {
        return self.min < x and x < self.max;
    }
};
