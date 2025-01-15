const bnd = @import("../../util/bounds.zig");
const vec = @import("../../util/vector.zig");
const c = @import("../../game/gameobjects/card.zig");
const rl = @import("../../engine/sdl2_render_layer.zig");
const sdl = @import("../../sdl.zig").c;
const std = @import("std");

pub const p_types = union(plant_types) {
    NONE: plant_none,
    CARROT: plant_carrot,
    WHEAT: plant_wheat,
};

pub const plant_types = enum {
    NONE,
    CARROT,
    WHEAT,
};

const plant_none = struct {};
const plant_carrot = struct {
    def_grow_time: i32 = 5,
};
const plant_wheat = struct {
    def_grow_time: i32 = 3,
};

pub const gameplot = struct {
    bounds: bnd.bounds = bnd.bounds{
        .x = 0,
        .y = 0,
        .w = 256,
        .h = 256,
    },
    active: bool = false,
    position: vec.vec2f = vec.vec2f{ .x = 0, .y = 0 },
    true_position: vec.vec2f = vec.vec2f{ .x = 854 / 2 - (256 / 2), .y = 0 },
    texture: *sdl.SDL_Texture = undefined,
    scale: f32 = 1.0,
    target_scale: f32 = 1.0,
    planted_crop: p_types = p_types{ .NONE = plant_none{} },
    remaining_growth_time: i32 = 0,
    played_cards: std.ArrayList(c.card),
    pub fn render(self: gameplot, renderer: ?*sdl.SDL_Renderer) void {
        rl.renderTexture(
            renderer,
            self.texture,
            self.bounds,
            self.position,
            self.scale,
        );
    }
};
