local Package = script.Parent

local Lex = require(script.Lex)
local Parse = require(script.Parse)
local Builder = require(script.Builder)
local ErrorHandling = require(Package.Errors)

return function(Source : string,Reference : {[string] : any})
    local Built
    local HasHeader = true
    pcall(function()
        local Tokens = Lex(Source)

        local AST = Parse(Tokens)

        if #ErrorHandling.ErrorLog > 0 then
            ErrorHandling.PrintErrorLog()
            return
        end

         if not AST.Header then 
            HasHeader = false
            return 
        end

        Built = Builder(AST,Reference)
    end)

    if #ErrorHandling.ErrorLog > 0 then 
        ErrorHandling.PrintErrorLog()
        return
    end

    if HasHeader == false then
        warn("Template files must have a header")
    end

    return Built
end
