const std = @import("std");
const ascii = std.ascii;
const token = @import("../token/token.zig");

const Allocator = std.mem.Allocator;

const Keyword = enum {
    FUNCTION,
    LET,
    TRUE,
    FALSE,
    IF,
    ELSE,
    RETURN,
};

const keywords = std.ComptimeStringMap(Keyword, .{
    .{ "fn", .FUNCTION },
    .{ "let", .LET },
    .{ "true", .TRUE },
    .{ "false", .FALSE },
    .{ "if", .IF },
    .{ "else", .ELSE },
    .{ "return", .RETURN },
});

const Lexer = struct {
    input: []const u8,
    pos: usize,
    readPosition: usize,
    ch: u8,

    pub fn readChar(self: *Lexer) void {
        if (self.readPosition >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.readPosition];
        }
        self.pos = self.readPosition;
        self.readPosition += 1;
    }

    pub fn nextToken(self: *Lexer) token.Token {
        self.skipWhitespace();
        const tok = token.Token{ .Type = token.ILLEGAL, .Literal = "" };
        switch (self.ch) {
            '=' => {
                if (self.peekChar() == '=') {
                    self.readChar();
                    tok = token.Token{ .Type = token.EQ, .Literal = "==" };
                } else {
                    tok = token.Token{ .Type = token.ASSIGN, .Literal = "=" };
                }
            },
            ';' => {
                tok = token.Token{ .Type = token.SEMICOLON, .Literal = ";" };
            },
            '(' => {
                tok = token.Token{ .Type = token.LPAREN, .Literal = "(" };
            },
            ')' => {
                tok = token.Token{ .Type = token.RPAREN, .Literal = ")" };
            },
            ',' => {
                tok = token.Token{ .Type = token.COMMA, .Literal = "," };
            },
            '+' => {
                tok = token.Token{ .Type = token.PLUS, .Literal = "+" };
            },
            '{' => {
                tok = token.Token{ .Type = token.LBRACE, .Literal = "{" };
            },
            '}' => {
                tok = token.Token{ .Type = token.RBRACE, .Literal = "}" };
            },
            0 => {
                tok = token.Token{ .Type = token.EOF, .Literal = "" };
            },
            else => {
                if (isLetter(self.ch)) {
                    const literal = self.readIdentifier();
                    tok = token.Token{ .Type = lookupIdent(literal), .Literal = literal };
                    return tok;
                } else if (ascii.isDigit(self.ch)) {
                    const literal = self.readNumber();
                    tok = token.Token{ .Type = token.INT, .Literal = literal };
                    return tok;
                } else {
                    tok = token.Token{ .Type = token.ILLEGAL, .Literal = self.ch };
                }
            },
        }
        self.readChar();
        return tok;
    }

    pub fn skipWhitespace(self: *Lexer) void {
        while (ascii.isWhitespace(self.ch)) {
            self.readChar();
        }
    }

    pub fn readIdentifier(self: *Lexer) []const u8 {
        const position = self.pos;
        while (isLetter(self.ch)) {
            self.readChar();
        }
        return self.input[position..self.pos];
    }

    pub fn lookupIdent(ident: []const u8) []const u8 {
        return keywords.get(ident);
    }

    pub fn readNumber(self: *Lexer) []const u8 {
        const position = self.pos;
        while (ascii.isDigit(self.ch)) {
            self.readChar();
        }
        return self.input[position..self.pos];
    }
};

fn new(allocator: Allocator, input: []const u8) !*Lexer {
    const l = allocator.create(Lexer){
        .input = input,
        .pos = 0,
        .readPosition = 0,
        .ch = 0,
    };

    l.readChar();
    return l;
}

fn isLetter(ch: u8) bool {
    return switch (ch) {
        'a'...'z', 'A'...'Z', '_' => true,
        else => false,
    };
}
