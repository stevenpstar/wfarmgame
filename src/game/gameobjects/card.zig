const bnd = @import("../../util/bounds.zig");
const vec = @import("../../util/vector.zig");
const rl = @import("../../engine/sdl2_render_layer.zig");
const sdl = @import("../../sdl.zig").c;
const textures = @import("../textures.zig");

pub const card_types = enum {
    NONE,
    CARROT,
    WHEAT,
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
    z_position: i32 = 0,
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
        card_types.WHEAT => {
            const wheat_card = card{
                .type = ct,
                .texture = textures.wheat_card_texture,
            };
            return wheat_card;
        },
    }
}

pub fn updateCard(c: *card, mouse_pos: vec.vec2i) void {
    if (c.dragged) {
        vec.lerpBounds(&c.bounds, vec.vec2f{
            .x = @as(f32, @floatFromInt(mouse_pos.x - 32)),
            .y = @as(f32, @floatFromInt(mouse_pos.y - 48)),
        }, 0.005);
    } else if (c.hovered) {
        vec.lerpBounds(&c.bounds, vec.vec2f{
            .x = c.true_position.x,
            .y = c.true_position.y - 8,
        }, 0.005);
    } else {
        vec.lerpBounds(&c.bounds, c.true_position, 0.002);
    }
    c.hovered = bnd.pointOverlaps(
        vec.vec2f{ .x = @as(f32, @floatFromInt(mouse_pos.x)), .y = @as(f32, @floatFromInt(mouse_pos.y)) },
        c.bounds,
    );
}
