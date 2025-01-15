const bnd = @import("../../util/bounds.zig");
const vec = @import("../../util/vector.zig");
const rl = @import("../../engine/sdl2_render_layer.zig");
const sdl = @import("../../sdl.zig").c;

const pb_x = 854 - 160;
const pb_y = (480 / 2) - 32;

pub const button_play_hand = struct {
    bounds: bnd.bounds = bnd.bounds{
        .x = pb_x,
        .y = pb_y,
        .w = 128,
        .h = 64,
    },
    texture: *sdl.SDL_Texture = undefined,
    pub fn render(self: button_play_hand, renderer: ?*sdl.SDL_Renderer) void {
        const b = bnd.bounds{
            .x = 0,
            .y = 0,
            .w = self.bounds.w,
            .h = self.bounds.h,
        };
        rl.renderTexture(
            renderer,
            self.texture,
            b,
            vec.vec2f{
                .x = pb_x,
                .y = pb_y,
            },
            1.0,
        );
    }
};
