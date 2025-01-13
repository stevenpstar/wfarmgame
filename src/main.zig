const std = @import("std");
const rl = @import("engine/sdl2_render_layer.zig");
const game = @import("game/gamescreen.zig");
const sdl = @import("sdl.zig").c;
const gs = @import("game/gamestate.zig");
const c = @import("game/gameobjects/card.zig");
const bnd = @import("util/bounds.zig");
const ran = @import("util/random.zig");

pub fn main() !void {
    // random
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.posix.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });

    ran.rand = prng.random();
    var quit: bool = false;
    var delta_time: f32 = 0.0;
    var tick_count: u32 = 0;

    const screenWidth = 854;
    const screenHeight = 480;
    const resX = 1920;
    const resY = 1080;

    var gamestate = gs.game_state{
        .max_hand_count = 10,
        .draw_card_amount = 5,
        .play_amount = 4,
        .hand = std.ArrayList(c.card).init(std.heap.page_allocator),
        .deck = std.ArrayList(c.card_types).init(std.heap.page_allocator),
        .playmat = std.ArrayList(c.card).init(std.heap.page_allocator),
        .playmat_bounds = bnd.bounds{
            .x = 854 / 2 - (316 / 2),
            .y = 240,
            .w = 316,
            .h = 128,
        },
    };
    defer gamestate.hand.deinit();
    defer gamestate.deck.deinit();
    defer gamestate.playmat.deinit();

    _ = sdl.SDL_Init(sdl.SDL_INIT_VIDEO);
    defer sdl.SDL_Quit();

    const window = sdl.SDL_CreateWindow(
        "Engine",
        sdl.SDL_WINDOWPOS_UNDEFINED,
        sdl.SDL_WINDOWPOS_UNDEFINED,
        resX,
        resY,
        0,
    );

    defer sdl.SDL_DestroyWindow(window);

    const renderer = sdl.SDL_CreateRenderer(
        window,
        -1,
        sdl.SDL_RENDERER_ACCELERATED,
    ) orelse {
        std.debug.print("uh oh", .{});
        return error.SDLInitializationFailed;
    };
    defer sdl.SDL_DestroyRenderer(renderer);

    _ = sdl.SDL_RenderSetLogicalSize(renderer, screenWidth, screenHeight);

    delta_time = @as(f32, @floatFromInt((sdl.SDL_GetTicks() - tick_count))) / 1000.0;
    tick_count = sdl.SDL_GetTicks();

    while (!quit) {
        quit = game.loop(delta_time, renderer, &gamestate);
    }
}
