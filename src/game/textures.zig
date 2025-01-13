const sdl = @import("../sdl.zig").c;
const rl = @import("../engine/sdl2_render_layer.zig");
const std = @import("std");

pub var carrot_card_texture: *sdl.SDL_Texture = undefined;
pub var playmat_texture: *sdl.SDL_Texture = undefined;

pub fn loadTextures(renderer: *sdl.SDL_Renderer) bool {
    carrot_card_texture = rl.createTexture(renderer, "assets/cards/carrotcard.png") orelse {
        return false;
    };
    playmat_texture = rl.createTexture(renderer, "assets/cards/playmat.png") orelse {
        return false;
    };
    return true;
}

pub fn freeTextures() void {
    std.debug.print("Freeing textures\n", .{});
    sdl.SDL_DestroyTexture(carrot_card_texture);
    sdl.SDL_DestroyTexture(playmat_texture);
}
