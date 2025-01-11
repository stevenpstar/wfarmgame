const v = @import("vector.zig");

pub const bounds = struct {
    x: f32 = 0.0,
    y: f32 = 0.0,
    w: f32 = 0.0,
    h: f32 = 0.0,
};

pub fn pointOverlaps(point: v.vec2, b: bounds) bool {
    return point.x >= b.position.x and
        point.x <= b.position.x + b.size.x and
        point.y >= b.position.y and
        point.y <= b.position.y + b.size.y;
}

pub fn boundsOverlap(a: bounds, b: bounds) bool {
    return a.x + a.w >= b.x and
        a.x <= b.x + b.w and
        a.y + a.h >= b.y and
        a.y <= b.y + b.h;
}
