
const string = @import("string.zig");
pub const RelationalOp = enum(u32){
    lt=0,// < less than
    gt=1,// > greater than
    le=2,// <= less than or equal
    ge=2,// >= greater than or equal
}
pub const EqualityOp = enum(u32){
    ae=4,// ~= approx equal
    sw=5,// ^= string starts with
    ew=6,// $=string ends with
    eq=7,// = equal
    ne=8,// != not equal
}
pub const BinaryOp = enum(u32){
    lt=0,
    gt=1,
    le=2,
    ge=2,
    ae=4,
    sw=5,
    ew=6,
    eq=7,
    ne=8,
}

pub const Character = enum(u32){
    Tab = 9,
    Lf = 10,
    Cr = 13,
    Space = 32,
    LParen = 40,
    RParen = 41,
    Comma = 44,
    Dot = 46,
    LBracket = 91,
    Backslash = 92,
    RBracket = 93,
    _0 = 48,
    _9 = 57,
    _ = 95,
    A = 64,
    Z = 90,
    a = 97,
    z = 122,
    DoubleQuote = 34,
    SingleQuote = 39,
    Exclaim = 33,
    Equal = 61,
    Caret = 94,
    Tilde = 126,
    Dollar = 36,
    Less = 60,
    Greater = 62,
    Bar = 124,
    Amp = 38
}
pub const Token = enum(u32){
    Eof = 0,
    Error,
    Identifier,
    Number,
    String,
    Comma,
    LParen,
    RParen,
    LBracket,
    RBracket,
    Exclaim,
    TildeEqual,
    CaretEqual,
    DollarEqual,
    EqualEqual,
    ExclaimEqual,
    Less,
    Greater,
    LessEqual,
    GreaterEqual,
    BarBar,
    AmpAmp
}
fn getEqualityOp(token: Token)?EqualityOp {
    switch (token) {
        .TildeEqual=> return "~=";
        .CaretEqual=> return "^=";
        .DollarEqual=> return "$=";
        .EqualEqual=> return "==";
        .ExclaimEqual=> return "!=";
        else => return null;
    }
}

fn getRelationalOp(token: Token)?RelationalOp {
    switch (token) {
        .Less =>return "<";
        .Greater =>return ">";
        .LessEqual =>return "<=";
        .GreaterEqual =>return ">=";
        else => return null;
    }
}

fn tokenSpell(token:Token)[]const u8{
    switch (token) {
        .Eof =>return "eof";
        .Error =>return "error";
        .Identifier =>return "identifier";
        .Number =>return "number";
        .String =>return "string";
        .Comma =>return ",";
        .LParen =>return "(";
        .RParen =>return ")";
        .LBracket =>return "[";
        .RBracket =>return "]";
        .Exclaim =>return "!";
        .TildeEqual =>return "~=";
        .CaretEqual =>return "^=";
        .DollarEqual =>return "$=";
        .EqualEqual =>return "==";
        .ExclaimEqual =>return "!=";
        .Less =>return "<";
        .Greater =>return ">";
        .LessEqual =>return "<=";
        .GreaterEqual =>return ">=";
        .BarBar =>return "||";
        .AmpAmp =>return "&&";
        else => @panic("invalid token");
    }
}

fn isSpace(codepoint: u32)bool {
    switch (codepoint) {
        Character.Tab,
        Character.Lf,
        Character.Cr,
        Character.Space => return true,
        else => return false,
    }
}

fn isNumber(codepoint: u32 )bool {
    return codepoint >= Character._0 && codepoint <= Character._9;
}

fn isLetter(codepoint: u32 ) bool {
    return (
        (codepoint >= Character.a && codepoint <= Character.z) ||
        (codepoint >= Character.A && codepoint <= Character.Z)
    );
}

fn isLetterOrNumber(codepoint: u32 )bool {
    return isLetter(codepoint) || isNumber(codepoint);
}

fn isIdentChar(codepoint: u32 )bool {
    return (
        isLetterOrNumber(codepoint) ||
        codepoint == Character._ ||
        codepoint == Character.Dollar ||
        codepoint == Character.Dot ||
        codepoint == Character.LBracket ||
        codepoint == Character.RBracket
    );
}


const Lexer = struct{
    const Self = @This();
    m_token:Token = Token.Error,
    m_index:usize = 0;
    m_char:u32 = Character.Lf,
    m_text?:[]const u8 = null,
    m_code:[]const u8,
    fn new(code:[]const u8)Self{
        return Self{
            .m_code = code,
        };
    }
    fn token(self:*const Self)Token{
        return self.m_token;
    }
    fn text(self:*const Self)[]const u8{
        return self.m_text orelse "";
    }
    fn yyinp(self:*Self){
        self.m_char = string.codePointAt(self.m_index) orelse 0;
        self.m_index += 1;
    }
    fn yylex(self:*Self)Token{
        self.m_text = null;
        while(isSpace(self.m_char)){
            self.yyinp();
        }
        if (self.m_char == 0) {
            return Token.Eof;
        }
        const ch = self.m_char;
        self.yyinp();
        switch (ch){
            Character.LParen => return Token.LParen;
            Character.RParen => return Token.RParen;
            Character.LBracket => return Token.LBracket;
            Character.RBracket => return Token.RBracket;
            Character.Comma => return Token.Comma;
            Character.SingleQuote,Character.DoubleQuote=>{
                const start = self.m_index - 1;
                while (self.m_char && self.m_char !== ch) {
                    // ### TODO handle escape sequences
                    self.yyinp();
                }
                if (self.m_char !== ch) {
                    @panic("Unfinished string literal");
                }
                self.yyinp();
                self.m_text = self.code.substring(start, self.m_index - 2);
                return Token.String;
            },
            Character.Exclaim =>{
                if (self.m_char == Character.Equal) {
                    self.yyinp();
                    return Token.ExclaimEqual;
                }
                return Token.Exclaim;
            },
            Character.Caret =>{
                if (self.m_char == Character.Equal) {
                    self.yyinp();
                    return Token.CaretEqual;
                }
                return Token.Error;
            },
            Character.Tilde =>{
                if (self.m_char == Character.Equal) {
                    self.yyinp();
                    return Token.TildeEqual;
                }
                return Token.Error;
            },
            Character.Equal =>{
                if (self.m_char == Character.Equal) {
                    self.yyinp();
                    return Token.EqualEqual;
                }
                return Token.Error;
            },
            Character.Less =>{
                if (self.m_char == Character.Equal) {
                    self.yyinp();
                    return Token.LessEqual;
                }
                return Token.Less;
            },
            Character.Greater =>{
                if (self.m_char == Character.Equal) {
                    self.yyinp();
                    return Token.GreaterEqual;
                }
                return Token.Greater;
            },
            Character.Bar =>{
                if (self.m_char == Character.Bar) {
                    self.yyinp();
                    return Token.BarBar;
                }
                return Token.Error;
            },
            Character.Amp =>{
                if (self.m_char == Character.Amp) {
                    self.yyinp();
                    return Token.AmpAmp;
                }
                return Token.Error;
            },
            else =>{
                const start = self.m_index - 2;
                if (
                    isLetter(ch) ||
                    ch == Character._ ||
                    (ch == Character.Dollar && isIdentChar(self.m_char))
                ) {
                    while (isIdentChar(self.m_char)) {
                        self.yyinp();
                    }
                    self.m_text = string.substring(self.code,start, self.m_index - 1);
                    return Token.Identifier;
                } else if (isNumber(ch)) {
                    while (isNumber(self.m_char)) {
                        self.yyinp();
                    }
                    if (self.m_char == Character.Dot) {
                        self.yyinp();
                        while (isNumber(self.m_char)) {
                            self.yyinp();
                        }
                    }
                    self.m_text = string.substring(self.code,start, self.m_index - 1);
                    return Token.Number;
                } else if (ch == Character.Dollar) {
                    if (self.m_char == Character.Equal) {
                        self.yyinp();
                        return Token.DollarEqual;
                    }
                    return Token.Error;
                }
            }
        }
    }
}

pub const ExprParser = struct{
    lex:Lexer,
    const Self = @This();
    pub fn new(code:[]const u8)Self{
        var self =  Self{
            .lex = Lexer.new(code),
        };
        self.lex.next();
        return self;
    }
    fn yyexpect(self:Self,token:Token)void{
        if (self.lex.token() != token) {
            @panic("expected " ++ tokenSpell(token) ++ " but got " ++ tokenSpell(self.lex.token()));
        }
        self.lex.next();
    }
}