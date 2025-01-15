const sdl = @import("../sdl.zig").c;
const rl = @import("../engine/sdl2_render_layer.zig");
const std = @import("std");

pub var carrot_card_texture: *sdl.SDL_Texture = undefined;
pub var wheat_card_texture: *sdl.SDL_Texture = undefined;
pub var playmat_texture: *sdl.SDL_Texture = undefined;
pub var plot2_texture: *sdl.SDL_Texture = undefined;

// UI

pub var play_button_texture: *sdl.SDL_Texture = undefined;

//

pub fn loadTextures(renderer: *sdl.SDL_Renderer) bool {
    carrot_card_texture = rl.createTexture(renderer, "assets/cards/carrotcard.png") orelse {
        return false;
    };
    wheat_card_texture = rl.createTexture(renderer, "assets/cards/wheatcard.png") orelse {
        return false;
    };

    plot2_texture = rl.createTexture(renderer, "assets/cards/plot_test2.png") orelse {
        return false;
    };

    playmat_texture = rl.createTexture(renderer, "assets/cards/playmat.png") orelse {
        return false;
    };

    // UI
    play_button_texture = rl.createTexture(renderer, "assets/cards/playbutton.png") orelse {
        std.debug.print("Could not load playbutton texture\n", .{});
        return false;
    };

    return true;
}

pub fn freeTextures() void {
    sdl.SDL_DestroyTexture(carrot_card_texture);
    sdl.SDL_DestroyTexture(wheat_card_texture);
    sdl.SDL_DestroyTexture(plot2_texture);
    sdl.SDL_DestroyTexture(playmat_texture);
    // free ui
    sdl.SDL_DestroyTexture(play_button_texture);
}
