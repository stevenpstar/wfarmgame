const bnd = @import("../../util/bounds.zig");
const vec = @import("../../util/vector.zig");
const rl = @import("../../engine/sdl2_render_layer.zig");
const sdl = @import("../../sdl.zig").c;
const textures = @import("../textures.zig");

pub const card_types = enum {
    NONE,
    CARROT,
};

pub const card = struct {
    type: card_types = card_types.NONE,
    bounds: bnd.bounds = bnd.bounds{
        .x = 0,
        .y = 0,
        .w = 64,
        .h = 96,
    },
    true_position: vec.vec2f = vec.vec2f{},
    hovered: bool = false,
    dragged: bool = false,
    texture: *sdl.SDL_Texture = undefined,
    pub fn render(self: card, renderer: ?*sdl.SDL_Renderer) void {
        // If not a real card entry in hand
        if (self.type == card_types.NONE) {
            return;
        }
        var b = bnd.bounds{ .x = 0, .y = 0, .w = 64, .h = 96 };

        if (self.hovered) {
            b.x = 64;
        }

        rl.renderTexture(
            renderer,
            self.texture,
            b,
            vec.vec2f{ .x = self.bounds.x, .y = self.bounds.y },
        );
    }
};

pub fn setCardType(c: *card, card_type: card_types, tex: *sdl.SDL_Texture) void {
    c.type == card_type;
    c.texture = &tex;
}

pub fn createCard(ct: card_types) card {
    switch (ct) {
        card_types.NONE => return card{},
        card_types.CARROT => {
            const carrot_card = card{
                .type = ct,
                .texture = textures.carrot_card_texture,
            };
            return carrot_card;
        },
    }
}
