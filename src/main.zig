const std = @import("std");
const rl = @import("engine/sdl2_render_layer.zig");
const game = @import("game/gamescreen.zig");
const sdl = @import("sdl.zig").c;

pub fn main() !void {
    var quit: bool = false;
    var delta_time: f32 = 0.0;
    var tick_count: u32 = 0;

    const screenWidth = 854;
    const screenHeight = 480;
    const resX = 1920;
    const resY = 1080;

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
        quit = game.loop(delta_time, renderer);
    }
}
