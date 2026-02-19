local SpecialCharacters = {
    ["<"] = true, [">"] = true, ["{"] = true,
    ["}"] = true, ["("] = true, [")"] = true,
    ["["] = true, ["]"] = true, [","] = true,
    [":"] = true, ["|"] = true, ["/"] = true,
}

local NewToken = function(Value,Type,Line,Column)
    return {
        Value = Value,
        Type = Type,
        Line = Line,
        Column = Column,
    }
end

local GetWords = function(Source : string)
    local index = 1

    local Temp = ""
    local Tokens = {}

    local PushTemp = function()
        if Temp == "" then return end

        table.insert(Tokens,Temp)
        Temp = ""
    end

    while index <= Source:len() do
        local current = Source:sub(index,index)
        index += 1

        if current == "\n" then
            PushTemp()
            table.insert(Tokens,">NEWLINE")
            continue
        end

        if current:find("%s") then
            PushTemp()
            continue
        end

        if current == '"' then
            PushTemp()
            local NextIndex = Source:find('"',index)
            Temp = Source:sub(index - 1,NextIndex)
            PushTemp()
            index = NextIndex + 1
            continue
        end

        if SpecialCharacters[current] then
            PushTemp()
            table.insert(Tokens,current)
            continue
        end

        Temp ..= current

    end

    PushTemp(Tokens, Temp)
    return Tokens
end

return function(Source)
    local Words = GetWords(Source)
    local Tokens = {}
    local index = 1

    local line = 1
    local column = 1

    while index <= #Words do
        local Current = Words[index]
        index += 1
        column += 1

        if Current == ">NEWLINE" then
            line += 1
            column = 0
            continue
        end

        local TYPE = ""

        if Current:sub(1,1) == '"' and Current:sub(Current:len(),Current:len()) == '"' then
            Current = Current:sub(2,Current:len() - 1)
            TYPE = "STRING"
        elseif tonumber(Current) then
            Current = tonumber(Current)
            TYPE = "NUMBER"
        elseif Current == "<" then
            TYPE = "BLOCK"
            local Value = Words[index]
            index += 1

            if Value == "/" then
                TYPE = "ENDBLOCK"
                Value = Words[index]
                index += 1
            end

            Current = Value
            index += 1
        elseif SpecialCharacters[Current] then
            TYPE = "SPECIAL"
        else
            TYPE = "IDENTIFIER"
        end

        if TYPE == "" then 
            print(`Could not tokenise: {Current}`) 
            continue 
        end

        table.insert(Tokens,NewToken(Current, TYPE,line,column))
    end
    
    return Tokens
end