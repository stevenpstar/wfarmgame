const bnd = @import("bounds.zig");

pub const vec2f = struct {
    x: f32 = 0.0,
    y: f32 = 0.0,
};

pub const vec2i = struct {
    x: i32 = 0,
    y: i32 = 0,
};

pub const vec4i = struct {
    x: i32 = 0,
    y: i32 = 0,
    z: i32 = 0,
    w: i32 = 0,
};

pub fn lerpVec2f(a: *vec2f, b: vec2f, t: f32) void {
    a.x *= (1 - t);
    a.y *= (1 - t);
    a.x += (b.x * t);
    a.y += (b.y * t);
}

pub fn lerpf(a: *f32, b: f32, t: f32) void {
    a.* *= (1 - t);
    a.* += (b * t);
}

pub fn lerpBounds(a: *bnd.bounds, b: vec2f, t: f32) void {
    a.x *= (1 - t);
    a.y *= (1 - t);
    a.x += (b.x * t);
    a.y += (b.y * t);
}
