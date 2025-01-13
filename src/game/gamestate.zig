const c = @import("gameobjects/card.zig");
const bnd = @import("../util/bounds.zig");
const std = @import("std");

pub const game_state = struct {
    max_hand_count: i32,
    draw_card_amount: i32,
    play_amount: i32 = 4,
    hand: std.ArrayList(c.card),
    deck: std.ArrayList(c.card),
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

pub fn playCard(ci: usize, gs: *game_state) bool {
    if (gs.playmat.items.len >= gs.play_amount) {
        return false;
    }

    if (!bnd.boundsOverlap(gs.hand.items[ci].bounds, gs.playmat_bounds)) {
        return false;
    }
    const pm_x = 854 / 2 - (281 / 2);
    const pm_len = @as(f32, @floatFromInt(gs.playmat.items.len));
    var card = removeCardFromHand(ci, gs);
    card.true_position.x = pm_x + (5 * pm_len) + (64 * pm_len) + 5;
    card.true_position.y = 240 + 16;
    card.dragged = false;
    gs.playmat.append(card) catch {
        return false;
    };
    gs.repositionHand();
    return true;
}
