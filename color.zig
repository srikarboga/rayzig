pub fn printColor(writer: anytype, color: @Vector(3, f32)) !void {
    const ir = @as(u32, @intFromFloat(255.999 * color[0]));
    const ig = @as(u32, @intFromFloat(255.999 * color[1]));
    const ib = @as(u32, @intFromFloat(255.999 * color[2]));

    try writer.print("{} {} {}\n", .{ ir, ig, ib });
}
