const c = @import("gameobjects/card.zig");
const bnd = @import("../util/bounds.zig");
const vec = @import("../util/vector.zig");
const rnd = @import("../util/random.zig");
const std = @import("std");

pub const game_state = struct {
    max_hand_count: i32,
    draw_card_amount: i32,
    play_amount: i32 = 4,
    hand: std.ArrayList(c.card),
    deck: std.ArrayList(c.card_types),
    playmat: std.ArrayList(c.card),
    playmat_bounds: bnd.bounds,
    fn repositionHand(self: game_state) void {
        const sw = 854;
        const center = (sw / 2);

        for (self.hand.items, 0..) |*card, i| {
            card.*.true_position.x = center + (@as(f32, @floatFromInt(i)) * 65) - (@as(f32, @floatFromInt(self.hand.items.len)) * 65 / 2);
            card.*.true_position.y = 380;
        }
    }
};

pub fn drawCard(gs: *game_state) void {
    if (gs.deck.items.len == 0) {
        return;
    }
    const card_to_draw = rnd.rand.intRangeLessThan(usize, 0, gs.deck.items.len);
    const ctype = gs.deck.orderedRemove(card_to_draw);
    const card = c.createCard(ctype);
    const added = addCardToHand(card, gs);
    if (!added) {
        std.debug.print("Could not add card to hand\n", .{});
    }
}

pub fn addCardToHand(card: c.card, gs: *game_state) bool {
    if (gs.hand.items.len >= gs.max_hand_count) {
        return false;
    }
    gs.hand.append(card) catch |err| {
        std.debug.print("Error occured when attempting to add card to hand {}\n", .{err});
        return false;
    };
    gs.repositionHand();
    return true;
}

fn removeCardFromHand(ci: usize, gs: *game_state) c.card {
    return gs.hand.orderedRemove(ci);
}

pub fn playCard(ci: usize, gs: *game_state, mouse_pos: vec.vec2i) bool {
    if (gs.playmat.items.len >= gs.play_amount) {
        return false;
    }

    if (!bnd.pointOverlaps(vec.vec2f{
        .x = @as(f32, @floatFromInt(mouse_pos.x)),
        .y = @as(f32, @floatFromInt(mouse_pos.y)),
    }, gs.playmat_bounds)) {
        return false;
    }

    const pm_x = 854 / 2 - (316 / 2);
    const pm_len = @as(f32, @floatFromInt(gs.playmat.items.len));
    var card = removeCardFromHand(ci, gs);
    card.true_position.x = pm_x + 5 + (10 * pm_len) + (64 * pm_len) + 10;
    card.true_position.y = 240 + 16;
    card.dragged = false;
    card.z_position = 0;
    gs.playmat.append(card) catch {
        return false;
    };
    gs.repositionHand();
    return true;
}

pub fn sortHand(gs: *game_state) void {
    std.mem.sort(c.card, gs.hand.items, {}, compareZPosition);
}

pub fn compareZPosition(context: void, a: c.card, b: c.card) bool {
    _ = context;
    if (a.z_position < b.z_position) {
        return true;
    }
    return false;
}
