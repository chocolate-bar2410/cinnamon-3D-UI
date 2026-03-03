local Package = script.Parent.Parent
local Lookup = require(Package.Lookup)

local ErrorHandling = require(Package.Errors)

local Schema = {}

local meta = {__index = Schema}

Schema.CurrentToken = function(self : Lookup.ParseHelper)
    if self.Position < 0 then return end

    return self.Tokens[self.Position]
end

Schema.Advance = function(self : Lookup.ParseHelper)
    local Token = self:CurrentToken()
    self.Position += 1
    return Token
end

Schema.GoBack = function(self : Lookup.ParseHelper)
    self.Position -= 1
    local Token = self:CurrentToken()
    
    return Token
end

Schema.CurrentTokenValue = function(self : Lookup.ParseHelper)
    if not self:CurrentToken() then return end

    return self:CurrentToken().Value
end

Schema.CurrentTokenType = function(self : Lookup.ParseHelper)
    if not self:CurrentToken() then return end

    return self:CurrentToken().Type
end

Schema.Expect = function(self : Lookup.ParseHelper,Value)
    local Token = self:Advance()

    if not Token then return end

    if Token.Value == Value then 
        return Token 
    end

    ErrorHandling.LogError("Parse",`Expected {Value} got {Token.Value}`,Token.Line,Token.Column)
    return nil
end

Schema.ExpectType = function(self : Lookup.ParseHelper,_Type)
    local Token = self:Advance()

    if not Token then return end

    if Token.Type == _Type then 
        return Token 
    end

    ErrorHandling.LogError("Parse",`Expected {_Type} got {Token.Type}`,Token.Line,Token.Column)
    return nil
end

Schema.LookAhead = function(self : Lookup.ParseHelper)
    return self.Tokens[self.Position + 1]
end


return function(AST,Tokens)
    local Parser = {}
    Parser.Tokens = Tokens
    Parser.Position = 1
    Parser.AST = AST 

    return setmetatable(Parser, meta)
end