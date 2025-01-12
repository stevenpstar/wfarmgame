const vec = @import("../util/vector.zig");
const rl = @import("../engine/sdl2_render_layer.zig");
const col = @import("../util/colours.zig");
const bnd = @import("../util/bounds.zig");
const sdl = @import("../sdl.zig").c;
const std = @import("std");

var carrot_card_texture: ?*sdl.SDL_Texture = undefined;

const plot = bnd.bounds{
    .x = 160,
    .y = 60,
    .w = 320,
    .h = 100,
};

const card = struct {
    bounds: bnd.bounds = bnd.bounds{
        .x = 0,
        .y = 0,
        .w = 64,
        .h = 96,
    },
    true_position: vec.vec2f = vec.vec2f{},
    hovered: bool = false,
    pub fn render(self: card, renderer: ?*sdl.SDL_Renderer) void {
        var b = bnd.bounds{ .x = 0, .y = 0, .w = 64, .h = 96 };

        if (self.hovered) {
            b.x = 64;
            std.debug.print("heyoo\n", .{});
        }

        rl.renderTexture(
            renderer,
            carrot_card_texture,
            b,
            vec.vec2f{ .x = self.bounds.x, .y = self.bounds.y },
        );

        // rl.setDrawColour(renderer, colour);
        // _ = sdl.SDL_RenderFillRect(renderer, &r);
    }
};

var c1 = card{
    .true_position = vec.vec2f{ .x = 160, .y = 200 },
};

pub fn loop(delta: f32, renderer: *sdl.SDL_Renderer) bool {
    var quit_loop: bool = false;
    var event: sdl.SDL_Event = undefined;
    var mouse_pos = vec.vec2i{ .x = 0, .y = 0 };

    const tex = rl.createTexture(renderer, "assets/logo.bmp");
    defer sdl.SDL_DestroyTexture(tex);

    carrot_card_texture = rl.createTexture(renderer, "assets/cards/carrotcard.png");
    defer sdl.SDL_DestroyTexture(carrot_card_texture);

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
            else => {},
        }
        update(delta, mouse_pos);
        render(renderer);
    }

    return quit_loop;
}
fn update(delta: f32, mouse_pos: vec.vec2i) void {
    _ = delta;
    vec.lerpBounds(&c1.bounds, c1.true_position, 0.001);
    c1.hovered = bnd.pointOverlaps(
        vec.vec2f{ .x = @as(f32, @floatFromInt(mouse_pos.x)), .y = @as(f32, @floatFromInt(mouse_pos.y)) },
        c1.bounds,
    );
}

fn render(
    renderer: ?*sdl.SDL_Renderer,
) void {
    rl.setDrawColour(renderer, col.BLACK);
    rl.renderClear(renderer);

    //    rl.renderTexture(
    //        renderer,
    //        tex,
    //        bnd.bounds{ .x = 0, .y = 0, .w = 64, .h = 96 },
    //        vec.vec2f{ .x = 640 - 64, .y = 0 },
    //    );

    const r: sdl.SDL_Rect = sdl.SDL_Rect{
        .x = @intFromFloat(plot.x),
        .y = @intFromFloat(plot.y),
        .w = @intFromFloat(plot.w),
        .h = @intFromFloat(plot.h),
    };
    rl.setDrawColour(renderer, col.GREEN);
    _ = sdl.SDL_RenderFillRect(renderer, &r);

    // Render cards
    c1.render(renderer);

    rl.render(renderer);
}
