const bnd = @import("../../util/bounds.zig");
const vec = @import("../../util/vector.zig");
const rl = @import("../../engine/sdl2_render_layer.zig");
const sdl = @import("../../sdl.zig").c;
const crd = @import("card.zig");

pub const hand = struct {
    cards: [5]*crd.card = undefined,
    pub fn addCard(self: *hand, card: crd.card) void {
        for (self.cards, 0..) |c, i| {
            if (c.type == crd.card_types.NONE) {
                self.cards[i].type = card.type;
                break;
            }
        }
    }
};
