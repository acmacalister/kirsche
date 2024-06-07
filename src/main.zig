const std = @import("std");
const repl = @import("repl.zig");

pub fn main() !void {
    std.debug.print("Welcome to Kirsche!\n", .{});
    const reader = std.io.getStdIn().reader().any();
    const writer = std.io.getStdOut().writer().any();
    try repl.start(reader, writer);
}
