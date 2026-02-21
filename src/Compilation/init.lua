local Package = script.Parent

local Lex = require(script.Lex)
local Parse = require(script.Parse)
local Builder = require(script.Builder)
local ErrorHandling = require(Package.Errors)

return function(Source : string,Reference : {[string] : any})
    local Tokens = Lex(Source)

    local AST = Parse(Tokens)

    if #ErrorHandling.ErrorLog > 0 then
        ErrorHandling.PrintErrorLog()
        return
    end

    local Built = Builder(AST,Reference)

    if #ErrorHandling.ErrorLog > 0 then 
        ErrorHandling.PrintErrorLog()
        return
    end

    return Built
end
