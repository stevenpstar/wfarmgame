const bnd = @import("../../util/bounds.zig");
const sdl = @import("../../sdl.zig").c;
const rl = @import("../../engine/sdl2_render_layer.zig");
const vec = @import("../../util/vector.zig");

pub const playmat = struct {
    bounds: bnd.bounds = bnd.bounds{
        .x = 0,
        .y = 0,
        .w = 316,
        .h = 128,
    },
    texture: *sdl.SDL_Texture = undefined,
    scale: f32 = 1.0,
    pub fn render(self: playmat, renderer: ?*sdl.SDL_Renderer) void {
        const b = bnd.bounds{ .x = 0, .y = 0, .w = 316, .h = 128 };

        rl.renderTexture(
            renderer,
            self.texture,
            b,
            vec.vec2f{ .x = 854 / 2 - (316 / 2), .y = 240 },
            self.scale,
        );
    }
};
