local Package = script.Parent.Parent
local ParseHelper = require(Package.Compilation.ParseHelper)
local Lookup = require(Package.Lookup)

local ParseMethods = {}

local ParseMap = {
    ["{"] = "Map",
    ["["] = "Array",
}

local ParseStatement = function(Parser : Lookup.ParseHelper)
    local Token : Lookup.CompileToken = Parser:CurrentToken()

    if not Token then return end

    local Node
    local Line = Token.Line
    if Token.Type == "STRING" or Token.Type == "IDENTIFIER" or Token.Type == "NUMBER" then
        Node = ParseMethods["Value"](Parser)
    elseif Token.Type == "BLOCK" then
        Node = ParseMethods["Block"](Parser)
    elseif ParseMap[Token.Value] then
        Node = ParseMethods[ParseMap[Token.Value]](Parser)
    end

    Node.Line = Line

    return Node
end

ParseMethods.Block = function(Parser : Lookup.ParseHelper)
    if Parser:CurrentTokenValue() == "container" then
        return ParseMethods["container"](Parser)
    elseif Parser:CurrentTokenValue() == "screencontainer" then
        return ParseMethods["screencontainer"](Parser)
    elseif Parser:CurrentTokenValue() == "timeline" then
        return ParseMethods["timeline"](Parser)
    end

    local StartBlock = Parser:Advance()
    local Properties = {}
    local BlockType = StartBlock.Value

    if Parser:CurrentTokenType() == "SPECIAL" and Parser:CurrentTokenValue() == "(" then
        return ParseMethods["Call"](Parser)
    end

    while Parser:CurrentToken() do

        if Parser:CurrentTokenType() == "ENDBLOCK" and Parser:CurrentTokenValue() == BlockType then 
            break 
        end

        Parser:Expect("|")

        Parser:ExpectType("IDENTIFIER")
        Parser:GoBack()

        local Identifier = ParseStatement(Parser)
        Parser:Expect(":")
        local Value = ParseStatement(Parser)

        Properties[Identifier.Value] = Value
    end

    Parser:Advance()

    return {NodeType = BlockType,Properties = Properties}
end

ParseMethods.container = function(Parser : Lookup.ParseHelper)
    Parser:Advance()
    local Properties = {}
    local Elements = {}

    while Parser:CurrentToken() do
        
        if Parser:CurrentTokenType() == "ENDBLOCK" and Parser:CurrentTokenValue() == "container" then 
            break 
        end

        if Parser:CurrentTokenType() == "BLOCK" and Parser:CurrentTokenValue() == "element" then
            local Element = ParseStatement(Parser)
            table.insert(Elements,Element)
            continue
        end

        Parser:Expect("|")

        Parser:ExpectType("IDENTIFIER")
        Parser:GoBack()

        local Identifier = ParseStatement(Parser)
        Parser:Expect(":")
        local Value = ParseStatement(Parser)

        Properties[Identifier.Value] = Value
    end

    Parser:Advance()

    return {NodeType = "UIContainer",Properties = Properties,Elements = Elements}
end

ParseMethods.screencontainer = function(Parser : Lookup.ParseHelper)
    Parser:Advance()
    local Properties = {}
    local Elements = {}

    while Parser:CurrentToken() do
        
        if Parser:CurrentTokenType() == "ENDBLOCK" and Parser:CurrentTokenValue() == "screencontainer" then 
            break 
        end

        if Parser:CurrentTokenType() == "BLOCK" and Parser:CurrentTokenValue() == "element" then
            local Element = ParseStatement(Parser)
            table.insert(Elements,Element)
            continue
        end

        Parser:Expect("|")

        Parser:ExpectType("IDENTIFIER")
        Parser:GoBack()

        local Identifier = ParseStatement(Parser)
        Parser:Expect(":")
        local Value = ParseStatement(Parser)

        Properties[Identifier.Value] = Value
    end

    Parser:Advance()

    return {NodeType = "screencontainer",Properties = Properties,Elements = Elements}
end

ParseMethods.timeline = function(Parser : Lookup.ParseHelper)
    Parser:Advance()
    local Properties = {}
    local TimelineEntries = {}

    while Parser:CurrentToken() do
        
        if Parser:CurrentTokenType() == "ENDBLOCK" and Parser:CurrentTokenValue() == "timeline" then 
            break 
        end

        Parser:Expect("|")

        if Parser:CurrentTokenValue() == "[" and Parser:CurrentTokenType() == "SPECIAL" then
            Parser:Advance()
            Parser:ExpectType("NUMBER")
            Parser:GoBack()
            local Duration = ParseStatement(Parser)
            
            Parser:Expect("]")
            Parser:ExpectType("ARROW")

            local Map = ParseStatement(Parser)

            table.insert(TimelineEntries,{Time = Duration,Data = Map})
            continue
        end

        Parser:ExpectType("IDENTIFIER")
        Parser:GoBack()

        local Identifier = ParseStatement(Parser)
        Parser:Expect(":")
        local Value = ParseStatement(Parser)

        Properties[Identifier.Value] = Value
    end

    Parser:Advance()

    return {NodeType = "timeline",Properties = Properties,TimelineEntries = TimelineEntries}
end

ParseMethods.Value = function(Parser : Lookup.ParseHelper)
    local Token = Parser:Advance()
    Token.NodeType = "Value"

    return Token
end

ParseMethods.Array = function(Parser : Lookup.ParseHelper)
    Parser:Advance()
    local Items = {}

    while Parser:CurrentToken() do

        if Parser:CurrentTokenType() == "SPECIAL" and Parser:CurrentTokenValue() == "]" then 
            break 
        end

        local Value = ParseStatement(Parser)
        table.insert(Items,Value)

        if Parser:CurrentTokenType() ~= "SPECIAL" or Parser:CurrentTokenValue() ~= "]" then 
            Parser:Expect(",")
  
        end

    end

    Parser:Advance()

    return {NodeType = "Array",Items = Items}
end

ParseMethods.Map = function(Parser : Lookup.ParseHelper)
    Parser:Advance()
    local Items = {}

    while Parser:CurrentToken() do

        if Parser:CurrentTokenType() == "SPECIAL" and Parser:CurrentTokenValue() == "}" then 
            break 
        end

        Parser:Expect("[")

        local Key = Parser:ExpectType("STRING")

        Parser:Expect("]")
        Parser:Expect(":")

        local Value = ParseStatement(Parser)
        Items[Key.Value] = Value

        if Parser:CurrentTokenType() ~= "SPECIAL" or Parser:CurrentTokenValue() ~= "}" then 
            Parser:Expect(",")
        end

    end

    Parser:Advance()

    return {NodeType = "Map",Items = Items}
end

ParseMethods.Call = function(Parser : Lookup.ParseHelper)
    Parser:GoBack()
    local Name = Parser:ExpectType("BLOCK")
    Parser:Expect("(")

    local Arguments = {}

    while Parser:CurrentToken() do

        if Parser:CurrentTokenType() == "SPECIAL" and Parser:CurrentTokenValue() == ")" then 
            break 
        end

        local Argument = ParseStatement(Parser)
        table.insert(Arguments,Argument)
        if Parser:CurrentTokenType() ~= "SPECIAL" or Parser:CurrentTokenValue() ~= ")" then 
            Parser:Expect(",")
        end
    end

    Parser:Advance()

    if Name then Name = Name.Value end

    return {NodeType = "Call", Name = Name, Arguments = Arguments}
end

return function(Tokens : {Lookup.CompileToken})
    local AST = {
        Header = {},
        Body = {},
    }

    local Parser = ParseHelper(AST, Tokens)

    while Parser:CurrentToken() do
        local Node = ParseStatement(Parser)

        if not Node then continue end

        if Node.NodeType == "header" then
            AST.Header = Node
            continue
        end

        table.insert(AST.Body,Node)
    end
    return AST
end