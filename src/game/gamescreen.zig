const vec = @import("../util/vector.zig");
const rl = @import("../engine/sdl2_render_layer.zig");
const col = @import("../util/colours.zig");
const bnd = @import("../util/bounds.zig");
const sdl = @import("../sdl.zig").c;
const std = @import("std");
const crd = @import("gameobjects/card.zig");
const pm = @import("gameobjects/playmat.zig");
const pl = @import("gameobjects/plot.zig");
const tex = @import("textures.zig");
const gs = @import("gamestate.zig");
const buttons = @import("ui/buttons.zig");

var playmat = pm.playmat{};
var play_button = buttons.button_play_hand{};

var deck = [10]crd.card_types{
    crd.card_types.CARROT,
    crd.card_types.CARROT,
    crd.card_types.CARROT,
    crd.card_types.CARROT,
    crd.card_types.CARROT,
    crd.card_types.WHEAT,
    crd.card_types.WHEAT,
    crd.card_types.WHEAT,
    crd.card_types.WHEAT,
    crd.card_types.WHEAT,
};

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
    play_button.texture = tex.play_button_texture;

    var gplot1 = pl.gameplot{
        .played_cards = std.ArrayList(crd.card).init(std.heap.page_allocator),
    };
    gplot1.texture = tex.plot2_texture;
    gplot1.active = true;

    var gplot2 = pl.gameplot{
        .played_cards = std.ArrayList(crd.card).init(std.heap.page_allocator),
    };
    gplot2.true_position = vec.vec2f{ .x = 854 / 2 - (854 / 8) - (256 / 2), .y = 0 };
    gplot2.texture = tex.plot2_texture;

    var gplot3 = pl.gameplot{
        .played_cards = std.ArrayList(crd.card).init(std.heap.page_allocator),
    };
    gplot3.true_position = vec.vec2f{ .x = 854 - (854 / 4) - (256 / 2), .y = 0 };
    gplot3.texture = tex.plot2_texture;
    // deinit plot played cards
    defer gplot1.played_cards.deinit();
    defer gplot2.played_cards.deinit();
    defer gplot3.played_cards.deinit();

    gamestate.gameplots.append(gplot1) catch {
        return false;
    };
    gamestate.gameplots.append(gplot2) catch {
        return false;
    };
    gamestate.gameplots.append(gplot3) catch {
        return false;
    };

    // TEST adding deck //

    for (deck) |ctype| {
        gamestate.deck.append(ctype) catch |err| {
            std.debug.print("Could not add card type to deck, err: {}\n", .{err});
            return false;
        };
    }

    // draw initial hand
    for (0..5) |_| {
        gs.drawCard(gamestate);
    }

    while (!quit_loop) {
        _ = sdl.SDL_PollEvent(&event);
        switch (event.type) {
            sdl.SDL_KEYDOWN => {
                if (event.key.keysym.sym == 'd') {
                    gs.drawCard(gamestate);
                } else if (event.key.keysym.sym == 'p') {
                    gamestate.goNextPlot();
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
                        card.*.z_position = 1;
                        gs.sortHand(gamestate);
                        break;
                    }
                }

                if (bnd.pointOverlaps(
                    vec.vec2f{
                        .x = @as(f32, @floatFromInt(event.motion.x)),
                        .y = @as(f32, @floatFromInt(event.motion.y)),
                    },
                    play_button.bounds,
                )) {
                    var i: usize = gamestate.playmat.items.len;
                    // For now we are just removing cards, but we should eventually do something with them
                    var active_plot: *pl.gameplot = undefined;
                    for (gamestate.gameplots.items) |*plot| {
                        if (plot.active) {
                            active_plot = plot;
                            break;
                        }
                    }
                    while (i > 0) {
                        i -= 1;
                        const c = gamestate.playmat.orderedRemove(i);
                        active_plot.played_cards.append(c) catch {
                            std.debug.print("Could not play card\n", .{});
                        };
                    }
                }
            },
            sdl.SDL_MOUSEBUTTONUP => {
                for (gamestate.hand.items, 0..) |*card, i| {
                    if (card.*.dragged) {
                        const played = gs.playCard(
                            i,
                            gamestate,
                            vec.vec2i{ .x = event.motion.x, .y = event.motion.y },
                        );
                        if (!played) {
                            card.*.dragged = false;
                            card.*.z_position = 0;
                        }
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

    for (gamestate.gameplots.items) |*plot| {
        vec.lerpf(&plot.scale, plot.target_scale, 0.002);
        vec.lerpVec2f(&plot.position, plot.true_position, 0.002);
        for (plot.played_cards.items, 0..) |*p_card, i| {
            p_card.*.true_position.x = plot.true_position.x + (128 * plot.scale) - (32 * p_card.scale) + (@as(f32, @floatFromInt(i)) * 8);
            p_card.*.true_position.y = plot.true_position.y + (64 * plot.scale) - (32 * p_card.scale);
            p_card.*.target_scale = plot.target_scale / 2.0;
            vec.lerpBounds(&p_card.bounds, p_card.true_position, 0.004);
            vec.lerpf(&p_card.scale, p_card.target_scale, 0.004);
        }
    }
}

fn render(renderer: ?*sdl.SDL_Renderer, gamestate: *gs.game_state) void {
    rl.setDrawColour(renderer, col.BLACK);
    rl.renderClear(renderer);

    // render plot (test)
    for (gamestate.gameplots.items) |*plot| {
        if (plot.active) {
            plot.*.target_scale = 1.0;
        } else {
            plot.*.target_scale = 0.5;
        }
        plot.render(renderer);
        for (plot.played_cards.items) |*p_card| {
            p_card.render(renderer);
        }
    }
    // render mat
    playmat.render(renderer);

    for (gamestate.playmat.items) |card| {
        card.render(renderer);
    }

    // render UI
    play_button.render(renderer);

    // Render cards
    for (gamestate.hand.items) |card| {
        card.render(renderer);
    }

    rl.render(renderer);
}
