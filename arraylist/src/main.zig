const std = @import("std");

pub fn main() !void {
    const a = std.heap.page_allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(a); // Release all allocated memory.

    try list.append(a, 1);
    try list.append(a, 2);
    try list.append(a, 3);

    for (list.items) |item| {
        std.debug.print("{d}\n", .{item});
    }
}
