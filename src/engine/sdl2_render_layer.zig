const vec = @import("../util/vector.zig");
const col = @import("../util/colours.zig");
const bnd = @import("../util/bounds.zig");
const std = @import("std");

const sdl = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub fn setDrawColour(
    renderer: ?*sdl.SDL_Renderer,
    colour: vec.vec4i,
) void {
    const r = std.math.clamp(colour.x, 0, 255);
    const g = std.math.clamp(colour.y, 0, 255);
    const b = std.math.clamp(colour.z, 0, 255);
    const a = std.math.clamp(colour.w, 0, 255);
    _ = sdl.SDL_SetRenderDrawColor(
        renderer,
        @intCast(r),
        @intCast(g),
        @intCast(b),
        @intCast(a),
    );
}

pub fn renderClear(renderer: ?*sdl.SDL_Renderer) void {
    _ = sdl.SDL_RenderClear(renderer);
}

pub fn render(renderer: ?*sdl.SDL_Renderer) void {
    _ = sdl.SDL_RenderPresent(renderer);
}

pub fn renderTexture(
    renderer: ?*sdl.SDL_Renderer,
    tex: ?*sdl.SDL_Texture,
    bounds: bnd.bounds,
    pos: vec.vec2f,
) void {
    const srcRect = sdl.SDL_Rect{
        .x = @intFromFloat(bounds.x),
        .y = @intFromFloat(bounds.y),
        .w = @intFromFloat(bounds.w),
        .h = @intFromFloat(bounds.h),
    };

    const destRect = sdl.SDL_Rect{
        .x = @intFromFloat(pos.x),
        .y = @intFromFloat(pos.y),
        .w = @intFromFloat(bounds.w),
        .h = @intFromFloat(bounds.h),
    };

    _ = sdl.SDL_RenderCopyEx(
        renderer,
        tex,
        &srcRect,
        &destRect,
        0.0,
        null,
        sdl.SDL_FLIP_NONE,
    );
}

pub fn createTexture(renderer: ?*sdl.SDL_Renderer, filePath: []const u8) ?*sdl.SDL_Texture {
    const surface = sdl.SDL_LoadBMP(filePath.ptr);
    if (surface == null) {
        std.debug.print("Error loading image file\n", .{});
        return null;
    }

    const texture = sdl.SDL_CreateTextureFromSurface(
        renderer,
        surface,
    );
    _ = sdl.SDL_FreeSurface(surface);

    return texture;
}
