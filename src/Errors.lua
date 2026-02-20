local EncodingService = game:GetService("EncodingService")
local module = {}

local Messagetab : {string} = {
    ["Parse"] = "error when parsing: %s",
    ["Compile"] = "error when compiling: %s"
}

module.ErrorLog = {}

module.LogError = function(ErrorType,ErrorMessage,Line,Column)
    local Message = Messagetab[ErrorType]:format(ErrorMessage)
    
    if Line and Column then
        Message ..= ` @ Line {Line} Col {Column}`
    end

    table.insert(module.ErrorLog,Message)
end

module.LogAssert = function(Condition,ErrorType,ErrorMessage,Line,Column)
    if Condition then return true end

    module.LogError(ErrorType, ErrorMessage, Line, Column)

    return false
end

module.PrintErrorLog = function()
    for _,v in module.ErrorLog do
        warn(v)
    end

    table.clear(module.ErrorLog)
end

module.PrintError = function(ErrorType,ErrorMessage,Line,Column)
    local Message = Messagetab[ErrorType]:format(ErrorMessage)
    
    if Line and Column then
        Message ..= ` @ Line {Line} Col {Column}`
    end

    warn(Message)
end

return module