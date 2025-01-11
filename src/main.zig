const std = @import("std");
const vec = @import("util/vector.zig");
const col = @import("util/colours.zig");
const bnd = @import("util/bounds.zig");
const rl = @import("engine/sdl2_render_layer.zig");

const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub fn main() !void {
    var quit: bool = false;
    var event: sdl.SDL_Event = undefined;

    const screenWidth = 640;
    const screenHeight = 480;

    _ = sdl.SDL_Init(sdl.SDL_INIT_VIDEO);
    defer sdl.SDL_Quit();

    const window = sdl.SDL_CreateWindow(
        "Engine",
        sdl.SDL_WINDOWPOS_UNDEFINED,
        sdl.SDL_WINDOWPOS_UNDEFINED,
        screenWidth,
        screenHeight,
        0,
    );

    defer sdl.SDL_DestroyWindow(window);

    const renderer = sdl.SDL_CreateRenderer(
        window,
        -1,
        sdl.SDL_RENDERER_ACCELERATED,
    );
    defer sdl.SDL_DestroyRenderer(renderer);

    const tex = rl.createTexture(renderer, "assets/logo.bmp");
    defer sdl.SDL_DestroyTexture(tex);

    while (!quit) {
        // Game Updating here
        rl.setDrawColour(renderer, col.BLACK);
        rl.renderClear(renderer);
        // Game Rendering here
        rl.renderTexture(
            renderer,
            tex,
            bnd.bounds{ .x = 0, .y = 0, .w = 64, .h = 64 },
            vec.vec2f{ .x = 320 - 32, .y = 240 - 32 },
        );
        rl.render(renderer);

        _ = sdl.SDL_PollEvent(&event);

        switch (event.type) {
            sdl.SDL_QUIT => quit = true,
            else => {},
        }
    }
}
