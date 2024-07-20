//Reference https://raytracing.github.io/books/RayTracingInOneWeekend.html
const std = @import("std");

pub fn main() !u8 {

    // Image

    const image_width: u16 = 256;
    const image_height: u16 = 256;

    //Render
    //printing basic info ab the image in ppm format
    var stdout = std.io.getStdOut().writer();
    try stdout.print("P3\n{} {}\n255\n", .{ image_width, image_height });
    for (0..image_height) |j| {
        for (0..image_width) |i| {
            const r = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(image_width - 1));
            const g = @as(f32, @floatFromInt(j)) / @as(f32, @floatFromInt(image_width - 1));
            const b = 0.0;

            const ir = @as(u32, @intFromFloat(255.999 * r));
            const ig = @as(u32, @intFromFloat(255.999 * g));
            const ib = @as(u32, @intFromFloat(255.999 * b));

            try stdout.print("{} {} {}\n", .{ ir, ig, ib });
        }
    }

    return 0;
}
