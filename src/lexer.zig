const std = @import("std");
const ascii = std.ascii;

pub const TokenType = enum {
    identifier,
    integer,
    illegal,
    eof,
    assign,
    plus,
    minus,
    bang,
    asterisk,
    fslash,
    comma,
    semicolon,
    lparen,
    rparen,
    lbrace,
    rbrace,
    ltag,
    rtag,
    equal,
    not_equal,
    function,
    let,
    true_op,
    false_op,
    if_op,
    else_op,
    return_op,
};

pub const Token = struct {
    Type: TokenType,
    Literal: []const u8 = "",
};

const keywords = std.ComptimeStringMap(TokenType, .{
    .{ "fn", .function },
    .{ "let", .let },
    .{ "true", .true_op },
    .{ "false", .false_op },
    .{ "if", .if_op },
    .{ "else", .else_op },
    .{ "return", .return_op },
});

pub const Lexer = struct {
    input: []const u8,
    pos: usize,
    readPosition: usize,
    ch: u8,

    pub fn init(input: []const u8) Lexer {
        return Lexer{
            .input = input,
            .pos = 0,
            .readPosition = 0,
            .ch = 0,
        };
    }

    pub fn nextToken(self: *Lexer) Token {
        self.skipWhitespace();
        const tok = switch (self.ch) {
            '=' => {
                if (self.peekChar() == '=') {
                    self.readChar();
                    return Token{ .Type = .equal, .Literal = "==" };
                } else {
                    return Token{ .Type = .assign, .Literal = "=" };
                }
            },
            ';' => Token{ .Type = .semicolon, .Literal = ";" },
            '(' => Token{ .Type = .lparen, .Literal = "(" },
            ')' => Token{ .Type = .rparen, .Literal = ")" },
            ',' => Token{ .Type = .comma, .Literal = "," },
            '+' => Token{ .Type = .plus, .Literal = "+" },
            '{' => Token{ .Type = .lbrace, .Literal = "{" },
            '}' => Token{ .Type = .rbrace, .Literal = "}" },
            0 => Token{ .Type = .eof, .Literal = "" },
            else => {
                if (isLetter(self.ch)) {
                    const literal = self.readIdentifier();
                    return Token{ .Type = lookupIdent(literal), .Literal = literal };
                } else if (ascii.isDigit(self.ch)) {
                    const literal = self.readNumber();
                    return Token{ .Type = .integer, .Literal = literal };
                } else {
                    return Token{ .Type = .illegal, .Literal = "" }; //&self.ch TODO: something with char
                }
            },
        };
        self.readChar();
        return tok;
    }

    fn skipWhitespace(self: *Lexer) void {
        while (ascii.isWhitespace(self.ch)) {
            self.readChar();
        }
    }

    fn readChar(self: *Lexer) void {
        if (self.readPosition >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.readPosition];
        }
        self.pos = self.readPosition;
        self.readPosition += 1;
    }

    fn peekChar(self: *Lexer) u8 {
        if (self.readPosition >= self.input.len) {
            return 0;
        } else {
            return self.input[self.readPosition];
        }
    }

    fn readIdentifier(self: *Lexer) []const u8 {
        const position = self.pos;
        while (isLetter(self.ch)) {
            self.readChar();
        }
        return self.input[position..self.pos];
    }

    fn lookupIdent(ident: []const u8) TokenType {
        return keywords.get(ident) orelse .illegal;
    }

    fn readNumber(self: *Lexer) []const u8 {
        const position = self.pos;
        while (ascii.isDigit(self.ch)) {
            self.readChar();
        }
        return self.input[position..self.pos];
    }
};

fn isLetter(ch: u8) bool {
    return switch (ch) {
        'a'...'z', 'A'...'Z', '_' => true,
        else => false,
    };
}
