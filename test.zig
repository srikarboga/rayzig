const std = @import("std");

pub fn main() void {
    const rand = std.crypto.random;
    const scalar: f64 = rand.float(f64);
    std.debug.print("{}", .{scalar});
}
