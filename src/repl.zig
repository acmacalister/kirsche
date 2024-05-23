const std = @import("std");
const io = std.io;
const lexer = @import("lexer.zig");

const prompt = ">> ";

pub fn start(in: io.AnyReader, out: io.AnyWriter) !void {
    while (true) {
        try out.print(prompt, .{});
        var buf: [1024]u8 = undefined;
        try in.streamUntilDelimiter(&buf, '\n', null);

        var l = lexer.Lexer.init(&buf);

        while (true) {
            const tok = l.nextToken();

            if (tok.Type == lexer.TokenType.eof) {
                break;
            }

            try out.print(" ", .{});
            try out.print("{any}", .{tok.Type});
            try out.print(": ", .{});
            try out.print("{any}", .{tok.Literal});
            try out.print("\n", .{});
        }
    }
}
