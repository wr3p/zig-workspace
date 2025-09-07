const std = @import("std");
const builtin = @import("builtin");

const hello_world = @import("hello_world/src/main.zig"); // hmmh :PPP
const arraylist = @import("arraylist/src/main.zig");

// thanks to https://stackoverflow.com/questions/62018241/current-way-to-get-user-input-in-zig
fn read_line(line_buffer: []u8, input: *std.Io.Reader) ![]u8 {
    var w: std.Io.Writer = .fixed(line_buffer);

    var line_length = try input.streamDelimiterLimit(&w, '\n', .unlimited);
    std.debug.assert(line_length <= line_buffer.len);

    if (builtin.os.tag == .windows) {
        if (line_length > 0) {
            var next_byte: ?u8 = null;

            if (input.peekByte()) |value| {
                next_byte = value;
            } else |err| switch (err) {
                error.EndOfStream => {
                    std.debug.assert(next_byte == null);
                },
                else => return err,
            }

            if (next_byte == '\n' and line_buffer[line_length - 1] == '\r') {
                line_length -= 1;
            }
        }
    }

    return line_buffer[0..line_length];
}

fn ask_project(line_buffer: []u8, input: *std.Io.Reader, output: *std.Io.Writer) !i64 {
    try output.writeAll("Project identifier (1 for hello_world): ");
    try output.flush();

    const input_line = try read_line(line_buffer, input);

    return std.fmt.parseInt(i64, input_line, 10);
}

pub fn main() !void {
    var stdin_reader_buffer: [1024]u8 = undefined;
    var stdout_write_buffer: [1024]u8 = undefined;
    var stdin = std.fs.File.stdin().reader(&stdin_reader_buffer);
    var stdout = std.fs.File.stdout().writer(&stdout_write_buffer);

    defer stdout.interface.flush() catch {};

    var line_buffer: [10]u8 = undefined;

    const id = try ask_project(line_buffer[0..], &stdin.interface, &stdout.interface);

    try stdout.interface.print("project id: {}", .{id});
    switch (id) {
        1 => try hello_world.main(),
        2 => try arraylist.main(),
        else => std.debug.print("Unknown project number!\n", .{}),
    }
}
