const std = @import("std");
const io = std.io;
const lexer = @import("lexer.zig");

const prompt = ">> ";

pub fn start(in: io.AnyReader, out: io.AnyWriter) !void {
    while (true) {
        try out.print(prompt, .{});
        var buffer: [1024]u8 = undefined;
        var stream = std.io.fixedBufferStream(&buffer);
        try in.streamUntilDelimiter(stream.writer(), '\n', null);

        var l = lexer.Lexer.init(&buffer);

        while (true) {
            const tok = l.nextToken();

            switch (tok.Type) {
                lexer.TokenType.eof => break,
                lexer.TokenType.illegal => break,
                else => {},
            }
            try out.print("{s}: {s}\n", .{ @tagName(tok.Type), tok.Literal });
        }
    }
}
