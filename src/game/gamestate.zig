const c = @import("gameobjects/card.zig");
const std = @import("std");

pub const game_state = struct {
    max_hand_count: i32,
    draw_card_amount: i32,
    hand: std.ArrayList(c.card),
    deck: std.ArrayList(c.card),
};

pub fn addCardToHand(card: c.card, gs: *game_state) bool {
    if (gs.hand.items.len >= gs.max_hand_count) {
        return false;
    }
    gs.hand.append(card) catch |err| {
        std.debug.print("Error occured when attempting to add card to hand {}\n", .{err});
        return false;
    };
    return true;
}
