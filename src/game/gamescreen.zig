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

    while (!quit_loop) {
        _ = sdl.SDL_PollEvent(&event);
        switch (event.type) {
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
                for (gamestate.hand.items) |*card| {
                    if (card.*.dragged) {
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
        if (card.dragged) {
            vec.lerpBounds(&card.bounds, vec.vec2f{
                .x = @as(f32, @floatFromInt(mouse_pos.x - 32)),
                .y = @as(f32, @floatFromInt(mouse_pos.y - 48)),
            }, 0.005);
        } else if (card.hovered) {
            vec.lerpBounds(&card.bounds, vec.vec2f{
                .x = card.true_position.x,
                .y = card.true_position.y - 8,
            }, 0.005);
        } else {
            vec.lerpBounds(&card.bounds, card.true_position, 0.001);
        }
        card.hovered = bnd.pointOverlaps(
            vec.vec2f{ .x = @as(f32, @floatFromInt(mouse_pos.x)), .y = @as(f32, @floatFromInt(mouse_pos.y)) },
            card.bounds,
        );
    }
}

fn render(renderer: ?*sdl.SDL_Renderer, gamestate: *gs.game_state) void {
    rl.setDrawColour(renderer, col.BLACK);
    rl.renderClear(renderer);

    const r: sdl.SDL_Rect = sdl.SDL_Rect{
        .x = @intFromFloat(plot.x),
        .y = @intFromFloat(plot.y),
        .w = @intFromFloat(plot.w),
        .h = @intFromFloat(plot.h),
    };
    rl.setDrawColour(renderer, col.GREEN);
    _ = sdl.SDL_RenderFillRect(renderer, &r);

    // render mat
    playmat.render(renderer);
    // Render cards
    for (gamestate.hand.items) |card| {
        card.render(renderer);
    }

    rl.render(renderer);
}
