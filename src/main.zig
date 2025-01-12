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
    var delta_time: f32 = 0.0;
    var tick_count: u32 = 0;

    const screenWidth = 640;
    const screenHeight = 360;
    const resX = 1920;
    const resY = 1080;
    var mx: c_int = 0;
    var my: c_int = 0;

    // test bounds for res testing
    const boundtest = bnd.bounds{
        .x = screenWidth / 2 - 32,
        .y = screenHeight / 2 - 32,
        .w = 64,
        .h = 64,
    };
    //

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
    );
    defer sdl.SDL_DestroyRenderer(renderer);

    _ = sdl.SDL_RenderSetLogicalSize(renderer, screenWidth, screenHeight);

    const tex = rl.createTexture(renderer, "assets/logo.bmp");
    defer sdl.SDL_DestroyTexture(tex);

    delta_time = @as(f32, @floatFromInt((sdl.SDL_GetTicks() - tick_count))) / 1000.0;
    tick_count = sdl.SDL_GetTicks();

    while (!quit) {
        // Game Updating here
        rl.setDrawColour(renderer, col.BLACK);
        rl.renderClear(renderer);
        // Game Rendering here
        rl.renderTexture(
            renderer,
            tex,
            bnd.bounds{ .x = 0, .y = 0, .w = 64, .h = 64 },
            vec.vec2f{ .x = screenWidth / 2 - 32, .y = screenHeight / 2 - 32 },
        );
        rl.render(renderer);

        _ = sdl.SDL_PollEvent(&event);

        switch (event.type) {
            sdl.SDL_QUIT => quit = true,
            sdl.SDL_MOUSEMOTION => {
                mx = event.motion.x;
                my = event.motion.y;
            },
            else => {},
        }

        if (bnd.pointOverlaps(
            vec.vec2f{ .x = @floatFromInt(mx), .y = @floatFromInt(my) },
            boundtest,
        )) {
            std.debug.print("Overlapping logo\n", .{});
        }
    }
}
