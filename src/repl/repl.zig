const std = @import("std");
const io = std.io;
const lexer = @import("../lexer/lexer.zig");

const prompt = ">> ";

pub fn start(allocator: std.mem.Allocator, in: io.AnyReader, out: io.AnyWriter) !void {
    while (true) {
        out.print(prompt);
        out.flush();

        const input = try io.readUntilDelimiter(allocator, in, '\n');
        defer allocator.free(input);
        if (input == null) {
            break;
        }

        const l = lexer.new(allocator, input);

        while (true) {
            const tok = l.nextToken();
            if (tok == null || tok.kind == lexer.TokenKind.EOF) {
                break;
            }
            out.print(" ");
            out.print(tok.kind);
            out.print(": ");
            out.print(tok.literal);
            out.println();
        }
    }
}
