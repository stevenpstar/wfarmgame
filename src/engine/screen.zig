// Premature abstraction for now will remain as is/not in use
pub const game_screen = struct {
    updateFn: *const fn (func: *anyopaque, dt: f32) anyerror!void,
    pub fn update(self: game_screen, delta: f32) !void {
        return self.updateFn(self.ptr, delta);
    }
};
