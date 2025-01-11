const vec = @import("vector.zig");

pub const BLACK = vec.vec4i{ .x = 0, .y = 0, .z = 0, .w = 255 };
pub const WHITE = vec.vec4i{ .x = 255, .y = 255, .z = 255, .w = 255 };
pub const RED = vec.vec4i{ .x = 255, .y = 0, .z = 0, .w = 255 };
pub const GREEN = vec.vec4i{ .x = 0, .y = 255, .z = 0, .w = 255 };
pub const BLUE = vec.vec4i{ .x = 0, .y = 0, .z = 255, .w = 255 };
