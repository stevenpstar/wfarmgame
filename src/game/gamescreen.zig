const vec = @import("../util/vector.zig");
const rl = @import("../engine/sdl2_render_layer.zig");
const col = @import("../util/colours.zig");
const bnd = @import("../util/bounds.zig");
const sdl = @import("../sdl.zig").c;
const std = @import("std");
const crd = @import("gameobjects/card.zig");
const pm = @import("gameobjects/playmat.zig");
const tex = @import("textures.zig");
const gs = @import("gamestate.zig");

const plot = bnd.bounds{
    .x = 160,
    .y = 60,
    .w = 320,
    .h = 100,
};

var playmat = pm.playmat{};

pub fn loop(delta: f32, renderer: *sdl.SDL_Renderer, gamestate: *gs.game_state) bool {
    const textures_loaded = tex.loadTextures(renderer);
    if (textures_loaded == false) {
        std.debug.print("Failed to load textures\n", .{});
        return false;
    }
    defer tex.freeTextures();
    var quit_loop: bool = false;
    var event: sdl.SDL_Event = undefined;
    var mouse_pos = vec.vec2i{ .x = 0, .y = 0 };

    playmat.texture = tex.playmat_texture;
    // TEST creating a carrot card //
    _ = gs.addCardToHand(crd.createCard(crd.card_types.CARROT), gamestate);
    _ = gs.addCardToHand(crd.createCard(crd.card_types.CARROT), gamestate);
    _ = gs.addCardToHand(crd.createCard(crd.card_types.CARROT), gamestate);

    while (!quit_loop) {
        _ = sdl.SDL_PollEvent(&event);
        switch (event.type) {
            sdl.SDL_KEYDOWN => {
                if (event.key.keysym.sym == 'd') {
                    _ = gs.addCardToHand(crd.createCard(crd.card_types.CARROT), gamestate);
                }
            },
            sdl.SDL_QUIT => {
                quit_loop = true;
                break;
            },
            sdl.SDL_MOUSEMOTION => {
                mouse_pos.x = @intCast(event.motion.x);
                mouse_pos.y = @intCast(event.motion.y);
            },
            sdl.SDL_MOUSEBUTTONDOWN => {
                for (gamestate.hand.items) |*card| {
                    if (bnd.pointOverlaps(
                        vec.vec2f{
                            .x = @as(f32, @floatFromInt(event.motion.x)),
                            .y = @as(f32, @floatFromInt(event.motion.y)),
                        },
                        card.bounds,
                    )) {
                        card.*.dragged = true;
                        break;
                    }
                }
            },
            sdl.SDL_MOUSEBUTTONUP => {
                for (gamestate.hand.items, 0..) |*card, i| {
                    if (card.*.dragged) {
                        const played = gs.playCard(i, gamestate);
                        if (!played) {
                            std.debug.print("No room in hand\n", .{});
                        }
                        card.*.dragged = false;
                    }
                }
            },
            else => {},
        }
        update(delta, mouse_pos, gamestate);
        render(renderer, gamestate);
    }

    return quit_loop;
}
fn update(delta: f32, mouse_pos: vec.vec2i, gamestate: *gs.game_state) void {
    _ = delta;
    for (gamestate.hand.items) |*card| {
        crd.updateCard(card, mouse_pos);
    }

    for (gamestate.playmat.items) |*card| {
        crd.updateCard(card, mouse_pos);
    }
}

fn render(renderer: ?*sdl.SDL_Renderer, gamestate: *gs.game_state) void {
    rl.setDrawColour(renderer, col.BLACK);
    rl.renderClear(renderer);

    // render mat
    playmat.render(renderer);

    for (gamestate.playmat.items) |card| {
        card.render(renderer);
    }

    // Render cards
    for (gamestate.hand.items) |card| {
        card.render(renderer);
    }

    rl.render(renderer);
}
